SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[cbp_is_order_cbp] (@ord_hdrnumber int, @strategy varchar(100), @rtn int Out)
AS
/************************************************************************************
NAME:       cbp_is_order_cbp
FILENAME:   tmwsp_cbp_is_order_cbp.sql
TYPE:       sybase stored proc
PURPOSE:    Determines if an order is considered to be a CBP order. The @strategy parameter is provided
            to allow different perspetives as to what a cbp order is in the future.  At the time of authoring
            the only strategy implemented was VERIFY_BY_MOVE_LOADED_INBOUND_EXCLUDE_CARRIER (see below)
            
            This majority of the code for this procedure was moved from ecomm_get_tp_for_order_sp.  The code
            was refactored as it was needed in more than one place (ebusiness/powerbuilder)
            

Strategies: 
            ------------------------------------------------
            VERIFY_BY_MOVE_LOADED_INBOUND_EXCLUDE_CARRIER
            ------------------------------------------------
            This strategy only considers an order to be a CBP order if the order is loaded Outside of the USA,
            enters the USA and does not have a carrier.
            
            
DATABASE:    TMW
RETURN CODES:
>0: Leg number crossing the border.
0 : Order is a CBP order
-1: Order is NOT a CBP order based on the strategy provided
-2: No strategy provided
-3: Invalid Order Number (must be > 0)
-4: Invalid strategy provided

Sample execution:

declare @rtn int

--valid execution, should return either 0 or -1 
exec @rtn = cbp_is_order_cbp 6649136,"VERIFY_BY_MOVE_LOADED_INBOUND_EXCLUDE_CARRIER"
exec @rtn = cbp_is_order_cbp 6649136,"VERIFY_BY_MOVE_LOADED_INBOUND"

--null/empty strategy, should return -2
exec @rtn = cbp_is_order_cbp 0,null

--Invalid order number, should return -3
exec @rtn = cbp_is_order_cbp 0,"VERIFY_BY_MOVE_LOADED_INBOUND_EXCLUDE_CARRIER"

--invalid strategy, should return -4
exec @rtn = cbp_is_order_cbp 6000000,'~~~~~~~'

--valid execution, should return the legheader number crossing the border
exec @rtn = cbp_is_order_cbp 6649398, "OBTAIN_LEG_OF_CROSSING"




REVISION LOG

DATE        WHO            REASON
----        ---            ------
12/12/06    kcd            Created
01/07/07    kcd            QA modifications
02/01/07    tjb            Added OBTAIN_LEG_OF_CROSSING strategy to obtain the legheader that is making
                           the border crossing.
02/13/07    tjb            An order is not CBP if the trading partner has been unlinked.
09/24/2007	DJM			   Modified to work with the TMWSuite current source database.
************************************************************************************/

DECLARE --@rtn int, 
        @mov_number int,
        @USA varchar(10),
        @countrycount int,
        @min_mfh_loaded int,
        @carrier varchar(12),
        @leg_count int,
        @first_border_cross_stop int,
        @stp_crossing_border int,
        @cbp_etp_id int,
        @crit_more_than_one_country int, 
        @crit_usa_is_involved int,
        @crit_loaded_outside_usa int ,
        @crit_ent_usa_aft_load_out_usa int,
        @crit_ent_usa_w_non_carrier int,
        @crit_single_leg_has_carrier int,
        @crit_single_leg int,
        @crit_unlinked int
        
        

--reset the criterion        
select  @crit_more_than_one_country=0,
        @crit_usa_is_involved=0,
        @crit_loaded_outside_usa=0,
        @crit_ent_usa_aft_load_out_usa=0,
        @crit_ent_usa_w_non_carrier=0,
        @crit_single_leg_has_carrier=0,
        @crit_single_leg=0,
        @crit_unlinked=0

--delare constants
select @USA = 'USA'

/* KCD 9-Jun-06 Create a temp table to store the countried involved in a move */
DECLARE @COUNTRY_ON_ORDER TABLE(
   ord_hdrnumber INT,
   country VARCHAR(50),
   stp_number INT NULL,
   stp_mfh_sequence INT NULL,  --TJB 26-Oct-06 Added so that it can be determined if inbound US order
   stp_type VARCHAR(6) NULL,  --TJB 26-Oct-06 Added so it can be determined if loaded
   stp_event CHAR(6) NULL, --TJB 26-Oct-06 Added so cbe stop can be found
   stp_tractor varchar(10) NULL,
   stp_driver1 varchar(10) NULL,
   stp_driver2 varchar(10) NULL,
   stp_carrier varchar(10) NULL,
   prev_stp_event CHAR(6) NULL, 
   prev_country varchar(50) NULL,
   prev_stp_type varchar(6) NULL,
   prev_stp_carrier varchar(10) NULL,
   prev_stp_tractor varchar(10) NULL,
   prev_stp_driver1 varchar(10) NULL,
   prev_stp_driver2 varchar(10) NULL,
   stp_sequence int null
   
)


/*****************************************************************************************************
 * 
 *                                   this code is common to all strategies
 *
 * 
 *****************************************************************************************************/

-- PTS 38765 - DJM - 09/21/2007 - Modified to default to the Strategy based on a new GI setting.
if ISNULL(@strategy, '') = '' 
	select @strategy = (select isNull(gi_string1,'') from generalinfo where gi_name = 'CBPDefaultStrategy')


--A non null/empty string strategy is required
IF ISNULL(@strategy, '') = '' 
   BEGIN
      SELECT @rtn = -2 
      GOTO DONE 
   END

--The order number must be greater than 0 (rules out s-invoices)
IF @ord_hdrnumber <= 0 
BEGIN
  SELECT @rtn = -3 
  GOTO DONE 
END

--Validate the strategy
if @strategy<>'VERIFY_BY_MOVE_LOADED_INBOUND_EXCLUDE_CARRIER' and
   @strategy<>'VERIFY_BY_MOVE_LOADED_INBOUND' and
   @strategy<> 'OBTAIN_LEG_OF_CROSSING'
BEGIN
  SELECT @rtn = -4
  GOTO DONE 
END



    
--get the move number, most strategies will need this.
SELECT @mov_number = mov_number 
   FROM orderheader 
   WHERE ord_hdrnumber = @ord_hdrnumber

--Default the return value to -1 (non cbp)
SELECT @rtn = -1

-- The FSS 'move' is being used because of the nature of the
-- stop construction.  Looking at the stops for an order could potentially miss
-- a CBP order.
--
--on each stop row,  there is a cmp_id, a stp_city and a stp_state.
--
--The cmp_id references a row in the company table, that has a cmp_city, and
--the cmp_city references a row in the city table, and that city has a cty_state.
--the cty_state will be looked up in the statecountry table to get the country.
--
--the stp_city references a row in the city table, and that city has a cty_state.
--the cty_state will be looked up in the statecountry table to get the country.
--
--the stp_state will be looked up in the statecountry table to get the country.
--
--All three will be looked up to ensure that data consistency across company/city and
--stops is maintained and that no holes exist.

if @mov_number>0
BEGIN
    --Work with the stp_state first.  Only join where it isn't null, not empty
    --string
    insert into @COUNTRY_ON_ORDER
    (
        ord_hdrnumber,
        country,
        stp_number,
        stp_mfh_sequence, --TJB 26-Oct-06
        stp_type, --TJB 26-Oct-06
        stp_event, --TJB 26-Oct-06
		stp_sequence
     )
        select
            @ord_hdrnumber, --TJB Stops ord_hdrnumber might be 0
            stc_country_c,
            stp_number,
            stp_mfh_sequence, --TJB 26-Oct-06
            stp_type, --TJB 26-Oct-06
            stp_event, --TJB 26-Oct-06
			stp_sequence	--DJM - PTS 38765
        from
            stops a,
            statecountry b
        where
            a.mov_number=@mov_number and
			a.ord_hdrnumber = @ord_hdrnumber and
            a.stp_state is not null and
            a.stp_state<> '' and
            a.stp_state=b.stc_state_c

        union
        --Work with the stp_city next.  Only join where it isn't 0
        select
            @ord_hdrnumber, --TJB Stops ord_hdrnumber might be 0
            stc_country_c,
            stp_number,
            stp_mfh_sequence, --TJB 26-Oct-06
            stp_type, --TJB 26-Oct-06
            stp_event, --TJB 26-Oct-06
			stp_sequence	--DJM - PTS 38765
        from
            stops a,
            statecountry b,
            city c
        where
            a.mov_number=@mov_number and
			a.ord_hdrnumber = @ord_hdrnumber and
            a.stp_city is not null and
            a.stp_city>0 and
            a.stp_city=c.cty_code and
            c.cty_state =b.stc_state_c

        union
        --finally, go after the cmp_id
        select
            @ord_hdrnumber,  --TJB Stops ord_hdrnumber might be 0
            stc_country_c,
            stp_number,
            stp_mfh_sequence, --TJB 26-Oct-06
            stp_type, --TJB 26-Oct-06
            stp_event, --TJB 26-Oct-06
			stp_sequence	--DJM - PTS 38765
        from
            stops a,
            statecountry b,
            city c,
            company d
        where
            a.mov_number=@mov_number and
			a.ord_hdrnumber = @ord_hdrnumber and
            isnull(a.cmp_id,'UNKNOWN')<>'UNKNOWN' and
            a.cmp_id<>'' and
            a.cmp_id = d.cmp_id and
            d.cmp_city = c.cty_code and
            c.cty_state =b.stc_state_c

      --Update the carrier information
      update @COUNTRY_ON_ORDER set
        stp_tractor=isnull(evt_tractor,'UNKNOWN'),
        stp_driver1=isnull(evt_driver1,'UNKNOWN'),
        stp_driver2=isnull(evt_driver2,'UNKNOWN'),
        stp_carrier=isnull(evt_carrier ,'UNKNOWN')
      from 
		@COUNTRY_ON_ORDER co inner join event e on co.stp_number = e.stp_number
      where
        e.evt_sequence=1
      
      
      --Update the previous stop information on each line (the first stop will have null values for the previous)
	  -- Modified to use the stp_sequence in case of Consolidated/Split trips.
      Update a
	  set a.prev_stp_event = b.stp_event,
        a.prev_country = b.country,
        a.prev_stp_type= b.stp_type,
        a.prev_stp_tractor= b.stp_tractor, 
        a.prev_stp_driver1= b.stp_driver1 ,
        a.prev_stp_driver2= b.stp_driver2,
        a.prev_stp_carrier= b.stp_carrier 
      from @COUNTRY_ON_ORDER as a
			join @COUNTRY_ON_ORDER as b on a.stp_sequence = (b.stp_sequence+1)
	
      --One last final update to fix any null values
      update @COUNTRY_ON_ORDER set
        stp_tractor=isnull(stp_tractor,'UNKNOWN'),
        stp_driver1=isnull(stp_driver1,'UNKNOWN'),
        stp_driver2=isnull(stp_driver2,'UNKNOWN'),
        stp_carrier=isnull(stp_carrier,'UNKNOWN'),
        prev_stp_tractor=isnull(prev_stp_tractor,'UNKNOWN'),
        prev_stp_driver1=isnull(prev_stp_driver1,'UNKNOWN'),
        prev_stp_driver2=isnull(prev_stp_driver2,'UNKNOWN'),
        prev_stp_carrier=isnull(prev_stp_carrier,'UNKNOWN')
      
      select 
        @countrycount = count(distinct country) 
      from
        @COUNTRY_ON_ORDER
END


/*****************************************************************************************************
 * Set up the criterion
 *****************************************************************************************************/

/**Set the more than one country criterion **/
if @countrycount>1 
BEGIN
    select @crit_more_than_one_country = 1
END 

/**Set the USA is involved criterion **/
if exists (select 'x' from @COUNTRY_ON_ORDER where country=@USA)
BEGIN
    select @crit_usa_is_involved=1
END

/**Set the loaded outside the USA criterion and the 'enters usa after loading' criterion**/
BEGIN
    --select the minimum stop sequence number where the type is pickup (PUP) and the country is not USA
    select 
        @min_mfh_loaded = min(stp_sequence)
    from 
        @COUNTRY_ON_ORDER
    where 
        stp_type = 'PUP' and country<>@USA

    if isnull(@min_mfh_loaded,0)>0 
    BEGIN
        select @crit_loaded_outside_usa=1
    END

    --See if there are any stops after this load that are in the USA.  If @min_mfh_loaded is 0 then
    --this means that it didn't load outside the usa. and this isn't considered to be CBP at this point
    if @crit_loaded_outside_usa=1 and exists (
        select 
            'x'
        from 
            @COUNTRY_ON_ORDER
        where 
            stp_sequence > @min_mfh_loaded and
            country=@USA)
    BEGIN
        select @crit_ent_usa_aft_load_out_usa=1
    END
END

/** Process our carrier criterion**/
BEGIN
    /* If a carrier is on an order, it is not a CBP order.  More specifically, the carrier must
     * be the resource that takes the loaded trailer across the border.
     * This is tricky to determine if there are multiple legs since we are concerned 
     * with the leg that is crossing the border.  See if we only have 1 leg and if that leg
     * has a carrier.  If so, then it isn't CBP.
     * If there multiple legs then we find the first stop that crosses into the USA
     * loaded and look at the resources on that stop
     */
    
    select 
        @leg_count = count(*) 
    from 
        legheader 
    where
        mov_number=@mov_number
    
    if @leg_count=1 
    BEGIN
        select @crit_single_leg=1
        if exists (select 'x' from @COUNTRY_ON_ORDER where stp_carrier<>'UNKNOWN')
        BEGIN
            select @crit_single_leg_has_carrier=1
        END
    END    

    if  @crit_single_leg=0 and
        @crit_loaded_outside_usa=1 and
        @crit_ent_usa_aft_load_out_usa=1
    BEGIN
        --Okay, look for what resource carried this arcross the USA border
        select 
            @first_border_cross_stop= min(stp_sequence) 
        from
            @COUNTRY_ON_ORDER
        where
            stp_sequence>@min_mfh_loaded AND --we are looking AFTER the first non-usa load
            country<>prev_country
            AND country=@USA  --Find the entry to the USA

        if isnull(@first_border_cross_stop,0)>0
        BEGIN
            select 
                @carrier = stp_carrier,
                @stp_crossing_border = stp_number --TJB 01-Feb-07 Store stop for later use              
            from
                @COUNTRY_ON_ORDER
            where
                stp_sequence=@first_border_cross_stop
            
            if @carrier='UNKNOWN'
            BEGIN
                select @crit_ent_usa_w_non_carrier=1
            END
        END
        
    END

END

/*Check if the order is unlinked for CBP */
--get the trading partner id for CBP
select @cbp_etp_id = 0

select @cbp_etp_id  = convert(int,gi_string1)
from generalinfo
where gi_name='cbp_etp_id'

--if exists (select 'x'
--           from ecomm_iteration_partners eip,
--                ecomm_orderheader eo
--           where eip.etp_id = @cbp_etp_id
--           and eip.eth_unlinked = 'Y'
--           and eo.eth_id = eip.eth_id
--           and eo.ord_hdrnumber = @ord_hdrnumber)
--begin
-- select @crit_unlinked = 1
--end 


/*****************************************************************************************************
 *                                   End of common code
 *****************************************************************************************************/


/*****************************************************************************************************
 * VERIFY_BY_MOVE_LOADED_INBOUND_EXCLUDE_CARRIER
 * 
 * An order is considered CBP if it loads outside the USA, and then enters the USA.  The resource that 
 * carries the load into the USA cannot be a carrier.  The order must not have been unlinked
 *****************************************************************************************************/
 
IF upper(@strategy)='VERIFY_BY_MOVE_LOADED_INBOUND_EXCLUDE_CARRIER'
BEGIN     
    if @crit_more_than_one_country=1 and
       @crit_usa_is_involved=1 and
       @crit_loaded_outside_usa=1 and
       @crit_ent_usa_aft_load_out_usa=1 and
       @crit_unlinked = 0 and
       ( (@crit_single_leg=1 and @crit_single_leg_has_carrier=0) or 
         (@crit_single_leg=0 and @crit_ent_usa_w_non_carrier=1)
       )
    BEGIN
        select @rtn=0
    END 
END

/*****************************************************************************************************
 * VERIFY_BY_MOVE_LOADED_INBOUND
 * 
 * An order is considered CBP if it loads outside the USA, and then enters the USA.  
 */

IF upper(@strategy)='VERIFY_BY_MOVE_LOADED_INBOUND'
BEGIN     
    if @crit_more_than_one_country=1 and
       @crit_usa_is_involved=1 and
       @crit_loaded_outside_usa=1 and
       @crit_ent_usa_aft_load_out_usa=1
    BEGIN
        select @rtn=0
    END 
END

/*****************************************************************************************************
 * OBTAIN_LEG_OF_CROSSING
 * 
 * Using the common code, determine the leg number doing the crossing. 
 *****************************************************************************************************/
IF upper(@strategy) = 'OBTAIN_LEG_OF_CROSSING'
BEGIN
  /* Ensure the stop number was stored */
  if isnull(@stp_crossing_border,0) > 0 
    begin
      /* Obtain the legheader number from the stops table */
      select @rtn = lgh_number
      from stops
      where stp_number = @stp_crossing_border
    end
END 
 

DONE:

/** Cleanup temp tables **/
--drop table @COUNTRY_ON_ORDER

return @rtn


GO
GRANT EXECUTE ON  [dbo].[cbp_is_order_cbp] TO [public]
GO
