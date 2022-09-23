SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[SCHILLI_V001_SP] (
	@pl_ord_hdrnumber int , -- the current order being settled 
	@pl_lgh_number int, -- the current trip segment being settled
	@pl_isprimary int, -- 0 or 1, 1 indicates that the revenue is being requested for linehaul settlement rate
	@ps_asgn_type varchar(6), -- indicates the type of asset, you can put conditional logic to determine rates based on this type
	@ps_asgn_id varchar(13), -- indicates the id of the asset
	@ps_paytype varchar(6), -- the paytype that the application found on the calculated revenue rate
	@pl_tarnum int, -- the tariff number on the rate being used
	@pl_disallowzeropaydetail int out, -- If you set this to 1 and the calc revenue is zero the app will not create a zero paydetail.
	@ps_returnmsg varchar(255) out, -- You should return a message to the application to indicate why the custom calculation failed.
	@pdec_calcrevenue money out, -- return the calculated revenue here. Populate this with -1 if the calculation fails
	@ps_loadstate varchar(3) OUT, -- Return the Load Status
	@pdc_rate decimal OUT -- Return the Rate	
					)
as 
/**
 *
 * COMMENTS:
    'SCHILLI'	Coded by Reed Dallman; SLM PTS 34054
**/


-- check the generalinfo table to determine if there is a valid custom revenue calc method
select @pdec_calcrevenue = -1
select @ps_returnmsg = 'No custom revenue method is currently supported.Custom calculated revenue methods are added based on customer requested billable Service Requests.'

-- BEGIN SCHILLI 
--Added simple case for non-split trips.  Original PTS was #34054
/*
* BEGIN SCHILLI - TEST CODE - NOT IN SOURCE 
Following is the info regarding the split trips that are paying a % per driver on tons 
1)      First Leg ? 46% to Rev Type 1: MDS  Rev Type 2: BIRMNG @$4.800/Ton 
        Second Leg ? 54% to Rev Type 1: MDS  Rev Type 2: DEMOP @$4.800/Ton 
 
2)      First Leg ? 48% to Rev Type 1: MDS  Rev Type 2: MEMPHS @ $8.926/Ton 
        Second Leg ? 52% to Rev Type 1:MDS  Rev Type 2: MEMPHS @ $8.926/Ton 
        Plus additional $10.00 to each driver/load to slipseat 
 
3)      First Leg ? 23% to Rev Type 1: TTI  Rev Type 2: BATESV  @ $4.400/Ton 
        Second Leg ? 77% to Rev Type 1: TTI  Rev Type 2: BATESV  @ $4.400/Ton 
*/ 
 
 
BEGIN 
declare @schilli_mov_number int 
declare @schilli_ord_revtype1 varchar(6) 
declare @schilli_drvtype2 varchar(6) 
declare @schilli_inv_lh_rev money 
declare @schilli_rev_per_ld_mile money 
declare @schilli_percent_tonnage money 
declare @schilli_ord_tonnage money 
declare @mov_ld_miles money
declare @schilli_ord_commodity varchar(8) 
declare @schilli_rate decimal (10,4)
declare @schilli_base_tariff int 
--select @schilli_base_tariff=1401
declare @schilli_test varchar(12) --PTS SLM 34811

        select @pl_isprimary = 1 
        select @pdec_calcrevenue = 0 
        select @schilli_mov_number = mov_number from legheader where lgh_number = @pl_lgh_number                
 

        if @pl_ord_hdrnumber > 0 
                and (select count(*) from legheader where mov_number=@schilli_mov_number)=1
 
 BEGIN
        select @schilli_ord_revtype1=(select ord_revtype1 from orderheader where ord_hdrnumber=@pl_ord_hdrnumber) 
        select @schilli_ord_tonnage=(select ord_totalweight from orderheader where ord_hdrnumber=@pl_ord_hdrnumber) 
	select @pdec_calcrevenue = (1*0.0005) * @schilli_ord_tonnage 
 END
 
        if @pl_ord_hdrnumber > 0 
                and (select count(*) from legheader where mov_number=@schilli_mov_number)=2 
 
        BEGIN 
        select @schilli_ord_revtype1=(select ord_revtype1 from orderheader where ord_hdrnumber=@pl_ord_hdrnumber) 
--        select @schilli_ord_tonnage=(select ord_totalweight from orderheader where ord_hdrnumber=@pl_ord_hdrnumber) 
        select @schilli_ord_tonnage=(select sum(stp_weight) from stops where ord_hdrnumber=@pl_ord_hdrnumber and stp_type='DRP')
        select @schilli_drvtype2=(select mpp_type2 from legheader where lgh_number=@pl_lgh_number) 
IF @schilli_ord_revtype1 = 'MDS' and @schilli_drvtype2 in ('BIRMNG','DEMOP') 
        BEGIN   
        set @schilli_percent_tonnage =  case 
                when @pl_lgh_number = (select min(lgh_number) from legheader where mov_number=@schilli_mov_number) 
                        then 0.46 
                when @pl_lgh_number = (select max(lgh_number) from legheader where mov_number=@schilli_mov_number) 
                        then 0.54 
                                        end 
        END 
IF @schilli_ord_revtype1 = 'MDS' and @schilli_drvtype2 in ('MEMPHS') 
        BEGIN 
        set @schilli_percent_tonnage =  case 
                when @pl_lgh_number = (select min(lgh_number) from legheader where mov_number=@schilli_mov_number) 
                        then 0.48 
                when @pl_lgh_number = (select max(lgh_number) from legheader where mov_number=@schilli_mov_number) 
                        then 0.52 
                                        end 
        END 
IF @schilli_ord_revtype1 = 'TTI' and @schilli_drvtype2 in ('BATESV') 
        BEGIN 
        set @schilli_percent_tonnage =  case 
                when @pl_lgh_number = (select min(lgh_number) from legheader where mov_number=@schilli_mov_number) 
                        then 0.23 
                when @pl_lgh_number = (select max(lgh_number) from legheader where mov_number=@schilli_mov_number) 
                        then 0.77 
                                        end 
        END 
 
select @pdec_calcrevenue = (@schilli_percent_tonnage*0.0005) * @schilli_ord_tonnage 
 
END
 

--same driver split scenario (designed for 1 split only)
--check to see if the same driver did all pieces of the split

--PTS 34811 SLM
select @schilli_test=(select tar_tariffitem from tariffheaderstl where tar_number=@pl_tarnum)
if isnumeric(@schilli_test) = 0
	select @ps_returnmsg = 'Referential tariff not properly specified in the Tariff Item Field.'
else
	begin
		select @schilli_base_tariff = @schilli_test
	
		if @pl_ord_hdrnumber > 0 
		 and (select count(*) from legheader where mov_number=@schilli_mov_number and lgh_driver1=@ps_asgn_id)
		      = (select count(*) from legheader where mov_number=@schilli_mov_number)
		 and (select lgh_split_flag from legheader where lgh_number=@pl_lgh_number) = 'F'
		 
		 BEGIN
		 --pay the final split leg based on total loaded miles
		 
		        select @schilli_ord_revtype1=(select ord_revtype1 from orderheader where ord_hdrnumber=@pl_ord_hdrnumber) 
		--        select @schilli_ord_tonnage=(select ord_totalweight from orderheader where ord_hdrnumber=@pl_ord_hdrnumber) 
		        select @schilli_ord_tonnage=(select sum(stp_weight) from stops where ord_hdrnumber=@pl_ord_hdrnumber and stp_type='DRP')
		 select @schilli_ord_commodity=(select cmd_code from orderheader where ord_hdrnumber=@pl_ord_hdrnumber) 
		 
		 select @mov_ld_miles =  sum(isnull(stp_lgh_mileage,0)) 
		    from stops 
		    where mov_number=@schilli_mov_number and stp_loadstatus='LD'
		 
				 select @schilli_rate = tra_rate 
		   from tariffratestl 
		      where tar_number=@schilli_base_tariff
		 and trc_number_col=
		 ( select trc_number 
		     from tariffrowcolumnstl 
		    where tar_number=@schilli_base_tariff and trc_rowcolumn='C' 
		           and (CHARINDEX(@schilli_ord_commodity, trc_multimatch) > 0))
		 and trc_number_row=
		 ( select trc_number
                     from tariffrowcolumnstl 
                   where tar_number=@schilli_base_tariff and trc_rowcolumn='R' and trc_rangevalue>=@mov_ld_miles 
                   and trc_sequence = (select min(trc_sequence)
	                               from tariffrowcolumnstl 
                             	       where tar_number=@schilli_base_tariff and trc_rowcolumn='R' and trc_rangevalue>=@mov_ld_miles )
	                               and tar_number=@schilli_base_tariff )
		 
		 select @pdec_calcrevenue = @schilli_rate * @schilli_ord_tonnage * 0.0005
	 
		 END
	END -- End for Test - isnumeric(@schilli_test)
END
-- END SCHILLI


GO
GRANT EXECUTE ON  [dbo].[SCHILLI_V001_SP] TO [public]
GO
