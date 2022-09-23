SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_broker_load_sp](
   @car_id varchar(8),
   @lgh_number int,
   @mov_number int,
   @lineHaul_payType varchar(6),
   @fuelCost_payType varchar(6),
   @accessorial_payType varchar(6)
)
AS

-- Create a temp table to hold the return resultset.
CREATE TABLE #temp (
   car_name          varchar(64) not null,
   car_contact          varchar(25) null,
   car_phone1        varchar(25) null,
   car_phone2        varchar(25) null,
   car_phone3        varchar(25) null,
   car_email         varchar(128) null,
   brk_lineHaul_charge     dec(12, 4) null,     -- blm   11.05.03 20514
   brk_fuel_charge      dec(12,4) null,      -- blm   11.05.03 20514
   brk_accessorial_charge     dec(12,4) null,      -- blm   11.05.03 20514
   lineHaul_charges     dec(12, 4) null,
   fuel_charges         dec(12,4) null,
   accessorial_charges     dec(12,4) null,
   total_charge         dec(12,4) null,
--    lineHaul_charge_currency   varchar(6) null,     -- blm   11.05.03 20514
--    fuel_charge_currency    varchar(6) null,     -- blm   11.05.03 20514
--    accessorial_charge_currency   varchar(6) null,     -- blm   11.05.03 20514
   brk_lineHaul_charge_currency  varchar(6) null,  -- blm   11.05.03 20514
   brk_fuel_charge_currency   varchar(6) null,     -- blm   11.05.03 20514
   brk_accessorial_charge_currency varchar(6) null,   -- blm   11.05.03 20514
   total_charge_currency      varchar(6) null,
   car_currency         varchar (6) null,
   car_country          varchar(6) null,
   ord_hdr_number       varchar(12) null,
   ord_charge_type         varchar(10) null,
   ord_quantity         dec(12,4) null,
   ord_unit       varchar(6) null,
   ord_line_haul        dec(12,4) null,
   ord_fuel_charge         dec(12,4) null,
   ord_accessorial      dec(12,4) null,
   ord_totalcharge         dec(12,4) null,
   ord_line_haul_currency     varchar(6) null,
   ord_fuel_charge_currency   varchar(6) null,
   ord_accessorial_currency   varchar(6) null,
   ord_totalcharge_currency   varchar(6) null,
   car_id            varchar(8) null,
   setl_seq_alloc       dec(12,4) null,
   setl_pay_type        int null,
   setl_quantity        dec(12,4) null,
   setl_unit         varchar(255) null,
   currency_visible     char(1) null,
   payrate           money null,
   ord_booked_revtype1_t      varchar(25) null,
   ord_booked_revtype1     varchar(12) null,
   ord_booked_revtype1_override  tinyint not null default(0),
      ord_booked_revtype1_tariff    int null,
   ord_booked_revtype1_rate   dec(12, 4) null,
   ord_booked_revtype1_amount dec(12, 4) null,
   lgh_booked_revtype1_t      varchar(25) null,
   lgh_booked_revtype1     varchar(12) null,
      lgh_booked_revtype1_override  tinyint not null default(0),
   lgh_booked_revtype1_tariff    int null,
   lgh_booked_revtype1_rate   dec(12, 4) null,
   lgh_booked_revtype1_amount dec(12, 4) null,
      lgh_carrier_truck    varchar(50) null,
      lgh_driver_name      varchar(255) null,
      lgh_driver_phone     varchar(25) null,
      lgh_truck_mcnum      varchar(25) null,
      lgh_outstatus        varchar(6) null ,
      lgh_trailernumber          varchar (25) null,
      broker_percent       decimal(8, 2) null,
      target_margin        money null,
      estimated_profit        money null,
      lgh_suggested_spend     money null,
      lgh_top_spend           money null,
   email_confirm           tinyint not null default(0),
   fax_confirm             tinyint not null default(0),
   print_confirm           tinyint not null default(0),
      external_equipment_id      int not null default(0) ,
   ch_user_id              varchar(20),   -- BDH 37106 9/10/07
   ch_status               varchar(20),   -- BDH 37106 9/10/07
   ch_datetime             datetime,   -- BDH 37106 9/10/07
   car_confirmpathname        varchar(256), -- KMM 45853 2/13/09
   car_204flag             tinyint not null default(0), -- KMM 45853 2/13/09,
   car_confirm_type        varchar (6) null, -- CGK 46011 5/27/2009
   car_confirm_ir_id       integer null, -- CGK 46011 5/27/2009
   car_confirm_irk_id         integer null -- CGK 46011 5/27/2009
,  tpr_id            VARCHAR(8) NULL  --PTS 48232 SPN
,  tpr_type       VARCHAR(20) NULL --PTS 48232 SPN
,  tpr_ord_number       VARCHAR(12) NULL --PTS 48232 SPN
,  tpr_payrate       MONEY NULL,       --PTS 48232 SPN
   ch_confirmation_received char(1) NULL,
   ch_id int not null,
   --PTS 55275 JJF 20110729
   lgh_type1 varchar(6) NULL,
   lgh_type1_t varchar(20) NULL
   --END PTS 55275 JJF 20110729
   --BEGIN PTS 60186 SPN
   , suggmile_fuel_charge MONEY NULL
   --END PTS 60186 SPN
   ,lgh_number       integer null		-- PTS 66406 - DJM - 1/8/2013
)

--BEGIN PTS 60186 SPN
DECLARE @t_suggmile_fuel_rate TABLE
( tra_rate           MONEY    NULL
, RowNum             INT      NULL
, ColNum             INT      NULL
, RowSeq             INT      NULL
, ColSeq             INT      NULL
, RowVal             MONEY    NULL
, ColVal             MONEY    NULL
, valid_count        INT      NULL
, tra_standardhours  MONEY    NULL
, tra_rateasflat     CHAR(1)  NULL
, tra_minqty         CHAR(1)  NULL
, tra_minrate        MONEY    NULL
)

DECLARE @dt_GetDate                 DATETIME
DECLARE @ACSSuggMileFuel_YN         VARCHAR(60)
DECLARE @ACSSuggMileFuel_TableID    VARCHAR(60)
DECLARE @ACSSuggMileFuel_TariffNo   VARCHAR(60)
DECLARE @ACSSuggMileFuel_rb         VARCHAR(10)
DECLARE @ACSSuggMileFuel_cb         VARCHAR(10)
DECLARE @ACSSuggMileFuel_afp_price  MONEY
DECLARE @suggmile_fuel_rate         MONEY
DECLARE @tra_rateasflat             CHAR(1)
DECLARE @tra_minqty                 CHAR(1)
DECLARE @tra_minrate                MONEY
DECLARE @acs_mile                   MONEY
DECLARE @suggmile_fuel_charge       MONEY
--END PTS 60186 SPN
DECLARE @leave_trailer				char (1) 
declare @trailer varchar (25)

-- LOR   PTS# 51908  added ch_confirmation_received, ch_id

--PTS 32651 - DJM - Added to get the current User.
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

SELECT @leave_trailer = gi_string1 FROM generalinfo WHERE gi_name = 'ACSLeaveTrailerAssign'
if @leave_trailer = 'Y'  
	SELECT @trailer = lgh_primary_trailer from legheader where lgh_number = @lgh_number 

Declare @loadrq   varchar(6)
select @loadrq = isNull(gi_string1,'') from generalinfo where gi_name = 'LoadBrokerConfirmLQtype'

declare @bookingtype varchar(25)
select @bookingtype = isNull(gi_string2,'Branch') from generalinfo where gi_name = 'TrackBranch'

declare @executingtype varchar(25)
select @executingtype = isNull(gi_string3,'Branch') from generalinfo where gi_name = 'TrackBranch'

-- LOR   PTS# 48567
Declare  @FSCPayTypes   varchar(60)
SELECT @FSCPayTypes = isnull(gi_string1,'')
FROM generalinfo
WHERE gi_name = 'FSCPayTypes'
If @FSCPayTypes <> ''
   select @FSCPayTypes = @FSCPayTypes + ','

-- PTS 36504 - JET - 3/26/2007, load in information from legheader cache so the window doesn't have to do it as a post process
declare @lgh_phone             varchar(25),
        @lgh_fax               varchar(25),
        @lgh_email             varchar(128),
        @lgh_contact           varchar(255),
        @lgh_carrier_truck     varchar(50),
        @lgh_truck_mcnum       varchar(25),
        @lgh_driver_name       varchar(255),
        @lgh_driver_phone      varchar(25),
        @lgh_trailernumber     varchar(50),
        @external_equipment_id int,
        @ord_booked_revtype1          varchar(12),
        @ord_booked_revtype1_override tinyint,
        @ord_booked_revtype1_rate     decimal(8, 4),
        @ord_booked_revtype1_amount   money,
        @lgh_booked_revtype1          varchar(12),
        @lgh_booked_revtype1_override tinyint,
        @lgh_booked_revtype1_rate     decimal(8, 4),
        @lgh_booked_revtype1_amount   money,
        @lgh_suggested_spend          money,
        @legheader_carid      varchar(8),
        @trip_linehaul_paytype   varchar(6),
        @trip_linehaul_paycode   int,
        @setl_pay_unit        varchar(6),
   @ch_user_id varchar(20),
   @ch_status varchar(20),
   @ch_datetime datetime,
   @ch_cnt int,
   @executingterminalfromleg CHAR(1),
   @ch_confirmation_received char(1),
   @ch_id int

--BEGIN PTS 48232 SPN
DECLARE @tpr_id      VARCHAR(8)
      , @tpr_type VARCHAR(20)
      , @tpr_ord_number VARCHAR(12)
      , @tpr_payrate MONEY
--END PTS 48232 SPN

--PTS 55275 JJF 20110729
DECLARE  @lgh_type1 varchar(6)
DECLARE @lgh_type_t varchar(20)
--END PTS 55275 JJF 20110729

--BEGIN PTS 56436 SPN
DECLARE @ACS_Exclude_ACC_PayType VARCHAR(60)
SELECT @ACS_Exclude_ACC_PayType = gi_string1
  FROM generalinfo
 WHERE gi_name = 'ACS_Exclude_ACC_PayType'
IF @ACS_Exclude_ACC_PayType IS NULL
   SELECT @ACS_Exclude_ACC_PayType = ',,'
ELSE
   SELECT @ACS_Exclude_ACC_PayType = ',' + @ACS_Exclude_ACC_PayType + ','
--END PTS 56436 SPN

--BEGIN PTS 60186 SPN
SELECT @dt_GetDate = dateadd(dd, datediff(dd,0, getDate()), 0)
--END PTS 60186 SPN

--PTS48841 MBR 09/23/09
SELECT @executingterminalfromleg = UPPER(LEFT(gi_string1, 1))
  FROM generalinfo
 WHERE gi_name = 'ExecutingTerminalFromLeg'
IF @executingterminalfromleg IS NULL
BEGIN
   SET @executingterminalfromleg = 'N'
END

select @ch_cnt = count(*) from confirmation_history where lgh_number = @lgh_number and mov_number = @mov_number
if @ch_cnt > 1
begin
   select @ch_user_id = ch_user_id,
      @ch_status = 'Re-Sent',
      @ch_datetime = ch_datetime,
      @ch_confirmation_received = IsNull(ch_confirmation_received, 'N'),
      @ch_id = ch_id
   from confirmation_history
   where lgh_number = @lgh_number and mov_number = @mov_number
   and ch_id = (select max(ch_id) from confirmation_history where lgh_number = @lgh_number and mov_number = @mov_number)
end
if @ch_cnt = 1
begin
   select @ch_user_id = ch_user_id,
      @ch_status = 'Sent',
      @ch_datetime = ch_datetime,
      @ch_confirmation_received = IsNull(ch_confirmation_received, 'N'),
      @ch_id = ch_id
   from confirmation_history
   where lgh_number = @lgh_number and mov_number = @mov_number
end
if @ch_cnt = 0
begin
   set @ch_user_id = ''
   set @ch_status = 'Not Sent'
   set @ch_datetime = ''
   set   @ch_confirmation_received = 'N'
   set @ch_id = 0
end

-- retrieve values from the legeheader_brokered table or reset to initial values
if (select count(*) from legheader_brokered where lgh_number = @lgh_number) > 0
   select @lgh_contact = case when ord_booked_carrier = 'UNKNOWN' then NULL else isnull(lgh_contact, '') end,
           @lgh_phone = case when ord_booked_carrier = 'UNKNOWN' then NULL else isnull(lgh_phone, '') end,
           @lgh_fax = case when ord_booked_carrier = 'UNKNOWN' then NULL else isnull(lgh_fax, '') end,
           @lgh_email = case when ord_booked_carrier = 'UNKNOWN' then NULL else isnull(lgh_email, '') end,
           @lgh_carrier_truck = isnull(lgh_carrier_truck, ''),
           @lgh_truck_mcnum = isnull(lgh_truck_mcnum, ''),
           @lgh_driver_name = isnull(lgh_driver_name, ''),
           @lgh_driver_phone = isnull(lgh_driver_phone, ''),
           @lgh_trailernumber = isnull(lgh_trailernumber, ''),
           @external_equipment_id = isnull(lgh_ete_id, 0),
           @ord_booked_revtype1 = isnull(ord_booked_revtype1, 'UNKNOWN'),
           @ord_booked_revtype1_override = isnull(ord_booked_revtype1_override, 0),
           @ord_booked_revtype1_rate = isnull(ord_booked_revtype1_rate, 0),
           @ord_booked_revtype1_amount = isnull(ord_booked_revtype1_amount, 0),
           @lgh_booked_revtype1 = isnull(lgh_booked_revtype1, 'UNKNOWN'),
           @lgh_booked_revtype1_override = isnull(lgh_booked_revtype1_override, 0),
           @lgh_booked_revtype1_rate = isnull(lgh_booked_revtype1_rate, 0),
           @lgh_booked_revtype1_amount = isnull(lgh_booked_revtype1_amount, 0),
           @lgh_suggested_spend = isnull(lgh_suggested_spend, 0),
           @legheader_carid = isnull(ord_booked_carrier, 'UNKNOWN')
      from legheader_brokered
     where lgh_number = @lgh_number
else
   select @lgh_contact = case when isnull(@car_id, 'UNKNOWN') <> 'UNKNOWN' then NULL else '' end,
           @lgh_phone = case when isnull(@car_id, 'UNKNOWN') <> 'UNKNOWN' then NULL else '' end,
           @lgh_fax = case when isnull(@car_id, 'UNKNOWN') <> 'UNKNOWN' then NULL else '' end,
           @lgh_email = case when isnull(@car_id, 'UNKNOWN') <> 'UNKNOWN' then NULL else '' end,
           @lgh_carrier_truck = '',
           @lgh_truck_mcnum = '',
           @lgh_driver_name = '',
           @lgh_driver_phone = '',
           @lgh_trailernumber = '',
           @external_equipment_id = 0,
           @ord_booked_revtype1 = 'UNKNOWN',
           @ord_booked_revtype1_override = 0,
           @ord_booked_revtype1_rate = 0,
           @ord_booked_revtype1_amount = 0,
           @lgh_booked_revtype1 = NULL,
           @lgh_booked_revtype1_override = 0,
           @lgh_booked_revtype1_rate = 0,
           @lgh_booked_revtype1_amount = 0,
           @lgh_suggested_spend = 0,
           @legheader_carid = 'UNKNOWN'


-- reset when carrier is UNKNOWN
If  isnull(@car_id, 'UNKNOWN') = 'UNKNOWN' Or isnull(@car_id, 'UNKNOWN') <> @legheader_carid
   select @lgh_contact = case when isnull(@car_id, 'UNKNOWN') <> 'UNKNOWN' then NULL else '' end,
           @lgh_phone = case when isnull(@car_id, 'UNKNOWN') <> 'UNKNOWN' then NULL else '' end,
           @lgh_fax = case when isnull(@car_id, 'UNKNOWN') <> 'UNKNOWN' then NULL else '' end,
           @lgh_email = case when isnull(@car_id, 'UNKNOWN') <> 'UNKNOWN' then NULL else '' end,
           @lgh_carrier_truck = '',
           @lgh_truck_mcnum = '',
           @lgh_driver_name = '',
           @lgh_driver_phone = '',
           @lgh_trailernumber = '',
           @external_equipment_id = 0,
           @lgh_booked_revtype1 = NULL,
           @lgh_booked_revtype1_override = 0,
           @lgh_booked_revtype1_rate = 0,
           @lgh_booked_revtype1_amount = 0

if @leave_trailer = 'Y' and @lgh_trailernumber = ''  
	SELECT @lgh_trailernumber = @trailer 

--PTS48841 MBR 09/23/09
IF @executingterminalfromleg = 'Y'
BEGIN
   SELECT @lgh_booked_revtype1 = lgh_booked_revtype1
     FROM legheader
    WHERE lgh_number = @lgh_number
END

--PTS 55275 JJF 20110808
SELECT   @lgh_type1 = lgh_type1
FROM  legheader
WHERE lgh_number = @lgh_number

SELECT   TOP 1 @lgh_type_t = userlabelname
FROM  labelfile
WHERE labeldefinition = 'LghType1'
--END PTS 55275 JJF 20110808

-- JET - 5/17/2007 - PTS 37557, the following code is put in to pin point the line haul pay type for
--     the settlement.  If the default is not found assigned to this trip then look for an alternate
if (select count(pyd_number)
      from paydetail
     where asgn_id = @car_id
       and asgn_type = 'CAR'
       and lgh_number= @lgh_number
       and mov_number= @mov_number
       and pyt_itemcode = @lineHaul_payType) < 1
begin
   -- pick one of the linehaul pay types assigned to this trip and asset
   select @trip_linehaul_paytype = min(pyt_itemcode)
     from paydetail
    where asgn_id = @car_id
      and asgn_type = 'CAR'
      and lgh_number= @lgh_number
      and mov_number= @mov_number
      and pyt_itemcode in (select pyt_itemcode
                       from paytype
                      where pyt_basis = 'LGH')
end

-- use the default value passed to this code if there wasn't a pay type assigned to the trip
set @trip_linehaul_paytype = ISNULL(@trip_linehaul_paytype, @lineHaul_payType)

-- lookup the code associated with the appropriate line haul pay code for the trip
select @trip_linehaul_paycode = pyt_number,
       @setl_pay_unit = pyt_unit
  from paytype
 where pyt_itemcode = @trip_linehaul_paytype
-- JET - 5/17/2007 - PTS 37557

--BEGIN PTS 48232 SPN
IF (SELECT COUNT(1)
      FROM thirdpartyassignment
     WHERE lgh_number = @lgh_number
       AND mov_number = @mov_number
       AND tpa_status <> 'DEL'
   ) > 1
   BEGIN
      SET @tpr_id   = 'Multiple'
   END
ELSE
   BEGIN
      SELECT @tpr_id         = tpr_id
           , @tpr_type       = tpr_type
           , @tpr_ord_number = ord_number
        FROM thirdpartyassignment
       WHERE lgh_number = @lgh_number
         AND mov_number = @mov_number
         AND tpa_status <> 'DEL'
   END
IF @tpr_id IS NULL
   SET @tpr_id = 'UNKNOWN'

IF @tpr_type IS NULL
   SET @tpr_type = 'UNK'

SELECT @tpr_payrate = SUM(pyd_amount)
  FROM paydetail
 WHERE asgn_type = 'TPR'
   AND lgh_number= @lgh_number
   AND mov_number= @mov_number
--END PTS 48232 SPN

-- LOR   PTS# 48567  added lineHaul_charges, fuel_charges, accessorial_charges
INSERT INTO #temp (car_name, car_contact, car_phone1, car_phone2, car_phone3, car_email,
                   brk_lineHaul_charge, brk_fuel_charge, brk_accessorial_charge, lineHaul_charges, fuel_charges, accessorial_charges,
                   total_charge, brk_lineHaul_charge_currency,
                  brk_fuel_charge_currency, brk_accessorial_charge_currency,
                   total_charge_currency, car_currency, car_country, ord_hdr_number,
                  ord_charge_type, ord_quantity, ord_unit, ord_line_haul, ord_fuel_charge,
                  ord_accessorial, ord_totalcharge, ord_line_haul_currency,
                  ord_fuel_charge_currency, ord_accessorial_currency,
                  ord_totalcharge_currency, car_id, setl_seq_alloc, setl_pay_type,
                  setl_quantity, setl_unit, currency_visible, payrate,
                   lgh_carrier_truck, lgh_truck_mcnum, lgh_driver_name, lgh_driver_phone, lgh_trailernumber, external_equipment_id,
                   ord_booked_revtype1_t, ord_booked_revtype1, ord_booked_revtype1_override, ord_booked_revtype1_rate, ord_booked_revtype1_amount,
                   lgh_booked_revtype1_t, lgh_booked_revtype1, lgh_booked_revtype1_override, lgh_booked_revtype1_rate, lgh_booked_revtype1_amount,
                   lgh_suggested_spend, ch_user_id, ch_status, ch_datetime, email_confirm, fax_confirm, print_confirm, car_204flag, car_confirmpathname,
               car_confirm_type, car_confirm_ir_id, car_confirm_irk_id  /*PTS 46011 CGK 5/27/2009*/
   /*BEGIN PTS 48232 SPN*/
   , tpr_id
   , tpr_type
   , tpr_ord_number
   , tpr_payrate
   /*END PTS 48232 SPN*/
   , ch_confirmation_received
   , ch_id
   --PTS 55275 JJF 20110729
   , lgh_type1
   , lgh_type1_t
   --END PTS 55275 JJF 20110729
   --BEGIN PTS 60186 SPN
   , suggmile_fuel_charge
   --END PTS 60186 SPN
   , lgh_number		-- PTS 66406 - DJM
   )
SELECT   car_name,
      case when @lgh_contact is NULL then car_contact else @lgh_contact end,
      case when @lgh_phone is NULL then car_phone1 else @lgh_phone end,
      car_phone2,
      case when @lgh_fax is NULL then car_phone3 else @lgh_fax end,
      case when @lgh_email is NULL then car_email else @lgh_email end,
      lineHaul_charge = isNull((select sum(pyd_amount)
                                    from PayDetail
                                   where asgn_id = @car_id
                                     and asgn_type = 'CAR'
                                     and lgh_number= @lgh_number
                                     and mov_number= @mov_number
                                     and pyt_itemcode = @trip_linehaul_paytype
                                     --and pyt_itemcode in (select pyt_itemcode
                                     --                       from paytype
                             --                      where pyt_basis = 'LGH')
                                  ), 0),
      fuel_charge = isNull((select sum(pyd_amount)
            from PayDetail
            where asgn_id = @car_id
            and asgn_type = 'CAR'
            and lgh_number= @lgh_number
            and mov_number= @mov_number
            and pyt_itemcode = @fuelCost_payType), 0),
      accessorial_charge = isNull((select sum(pyd_amount)
               from PayDetail
               where asgn_id = @car_id
               and asgn_type = 'CAR'
               and lgh_number= @lgh_number
               and mov_number= @mov_number
               --and pyt_itemcode not in (select pyt_itemcode
               --          from paytype
               --          where pyt_basis = 'LGH')
                    and pyt_itemcode = @accessorial_payType), 0), --<> @fuelCost_payType), 0),

      lineHaul_charges = isNull((select sum(pyd_amount)
                                    from PayDetail
                                   where asgn_id = @car_id
                                     and asgn_type = 'CAR'
                                     and lgh_number= @lgh_number
                                     and mov_number= @mov_number and
                                      pyt_itemcode in (select pyt_itemcode
                                          from paytype
                                          where pyt_basis = 'LGH' and pyt_itemcode not in (@trip_linehaul_paytype))
                                  ), 0),
      fuel_charges = isNull((select sum(pyd_amount)
                        from PayDetail
                        where asgn_id = @car_id
                        and asgn_type = 'CAR'
                        and lgh_number= @lgh_number
                        and mov_number= @mov_number and
                           CHARINDEX(pyt_itemcode + ',', @FSCPayTypes) > 0
                        and pyt_itemcode not in (@fuelCost_payType)
                     ), 0),

      accessorial_charges = isNull((select sum(pyd_amount)
                              from PayDetail
                              where asgn_id = @car_id
                              and asgn_type = 'CAR'
                              and lgh_number= @lgh_number
                              and mov_number= @mov_number
                              and pyt_itemcode not in (select pyt_itemcode
                                                from paytype
                                                where pyt_basis = 'LGH') and
                                 pyt_itemcode not in (@accessorial_payType, @fuelCost_payType) and
                                 CHARINDEX(pyt_itemcode + ',', @FSCPayTypes) <= 0
                                 --BEGIN PTS 56436 SPN
                                 AND CHARINDEX(pyt_itemcode + ',', @ACS_Exclude_ACC_PayType) <= 0
                                 --END PTS 56436 SPN
                        ), 0),

-- MRH The code below will only return the pay that matches the paytype
--       brk_lineHaul_charge = isNull((select sum(pyd_amount)
--                from PayDetail
--                where asgn_id = @car_id
--                and asgn_type = 'CAR'
--                and lgh_number= @lgh_number
--                and mov_number= @mov_number
--                and pyt_itemcode = @lineHaul_payType), 0),
--       brk_fuel_charge = isNull((select sum(pyd_amount)
--                from PayDetail
--                where asgn_id = @car_id
--                and asgn_type = 'CAR'
--                and lgh_number= @lgh_number
--                and mov_number= @mov_number
--                and pyt_itemcode = @fuelCost_payType), 0),   -- blm   11.05.03 20514
--    --          and pyt_itemcode = 'FULTRC'), 0),   -- blm   11.05.03 20514
--       brk_accessorial_charge = isNull((select sum(pyd_amount)
--                from PayDetail
--                where asgn_id = @car_id
--                and asgn_type = 'CAR'
--                and lgh_number= @lgh_number
--                and mov_number= @mov_number
--                and pyt_itemcode in (select pyt_itemcode
--                            from paytype
--                            where pyt_basis = 'ANC') and pyt_itemcode not in(@lineHaul_payType, @fuelCost_payType)), 0), -- blm   11.05.03 20514
--             or pyt_itemcode not in (@lineHaul_payType, @fuelCost_payType)), 0),
--             and pyt_itemcode = @accessorial_payType), 0),         -- blm   11.05.03 20514
-- blm   11.05.03 20514  - begin
--                and pyt_itemcode not in (select pyt_itemcode
--                            from paytype
--                            where pyt_basis = 'LGH') and pyt_itemcode <> 'FULTRC'), 0), -- blm   11.05.03 20514
-- blm   11.05.03 20514  - end
      0 total_charge,
      brk_lineHaul_charge_currency = (select max(pyd_currency)
               from PayDetail
               where asgn_id = @car_id
               and asgn_type = 'CAR'
               and lgh_number= @lgh_number
               and mov_number= @mov_number
               and pyt_itemcode = @trip_linehaul_paytype),
--                and pyt_itemcode in (select pyt_itemcode
--                         from paytype
--                         where pyt_basis = 'LGH')),
      brk_fuel_charge_currency = (select max(pyd_currency)
            from PayDetail
            where asgn_id = @car_id
            and asgn_type = 'CAR'
            and lgh_number= @lgh_number
            and mov_number= @mov_number
            and pyt_itemcode = @fuelCost_payType),    -- blm   11.05.03 20514
--          and pyt_itemcode = 'FULTRC'),    -- blm   11.05.03 20514
      brk_accessorial_charge_currency = (select max( pyd_currency)
               from PayDetail
               where asgn_id = @car_id
               and asgn_type = 'CAR'
               and lgh_number= @lgh_number
               and mov_number= @mov_number
               and pyt_itemcode = @accessorial_payType),       -- blm   11.05.03 20514
-- blm   11.05.03 20514  - begin
--             and pyt_itemcode not in (select pyt_itemcode
--                         from paytype
--                         where pyt_basis = 'LGH') and pyt_itemcode <> 'FULTRC'),
-- blm   11.05.03 20514  - end
--    '' other_charges_currency,
      '' total_charge_currency,
--    car_currency = tmw_get_currency('CAR', @car_id),
--    car_country = tmw_get_country('CAR', @car_id),
      (SELECT case pto_id
         when 'UNKNOWN' then car_currency
         else (select pto_currency from payto where payto.pto_id = carrier.pto_id)
               end
         FROM   carrier
         WHERE  car_id = @car_id) car_currency,
      isnull((SELECT car_country from carrier where car_id = @car_id),'') car_country,
      '' ord_hdr_number,
      '' ord_charge_type,
      0 ord_quantity,
      ' ' ord_unit,
      0 ord_line_haul,
      0 ord_fuel_charge,
      0 ord_accessorial,
      0 ord_totalcharge,
      '' ord_line_haul_currency,
      '' ord_fuel_charge_currency,
      '' ord_accessorial_currency,
      '' ord_totalcharge_currency,
      car_id,
      0 setl_seq_alloc,
        setl_pay_type = isNull((select pyt_number
                                  from paytype
                                 where pyt_itemcode = @trip_linehaul_paytype), 0),
      -- JET - 5/17/2007 - PTS 37557, added 1 for flat and returned total quantity when other units are used
      setl_quantity = case when @setl_pay_unit = 'FLT' then 1
                        else (select sum(pyd_quantity)
                           from PayDetail
                          where asgn_id = @car_id
                            and asgn_type = 'CAR'
                            and lgh_number= @lgh_number
                            and mov_number= @mov_number
                                 and pyt_itemcode = @trip_linehaul_paytype)   end,
                                 --and pyt_itemcode in (select pyt_itemcode
                                 --                       from paytype
                                 --                      where pyt_basis = 'LGH')),
      -- JET - 5/17/2007 - PTS 37557, returned the units for the pay type selected (from paytype table)
      @setl_pay_unit setl_unit,
      'Y',
      payrate = isNull((select max(pyd_rate)
               from PayDetail
               where asgn_id = @car_id
               and asgn_type = 'CAR'
               and lgh_number= @lgh_number
               and mov_number= @mov_number
               and pyt_itemcode = @trip_linehaul_paytype),0),
        @lgh_carrier_truck, @lgh_truck_mcnum, @lgh_driver_name, @lgh_driver_phone, @lgh_trailernumber, @external_equipment_id,
        @bookingtype, @ord_booked_revtype1, @ord_booked_revtype1_override, @ord_booked_revtype1_rate, @ord_booked_revtype1_amount,
        @executingtype, Case when @lgh_booked_revtype1 is NULL then isnull(car_branch, 'UNKNOWN') else @lgh_booked_revtype1 end,
                        @lgh_booked_revtype1_override, @lgh_booked_revtype1_rate, @lgh_booked_revtype1_amount,
        @lgh_suggested_spend ,@ch_user_id, @ch_status, @ch_datetime, isnull(car_confirmemail,0), isnull(car_confirmfax,0),
        isnull(car_confirmprint,0), isnull(car_204flag,0), car_confirmpathname, car_confirm_type, car_confirm_ir_id,
        car_confirm_irk_id /*PTS 46011 CGK 5/27/2009*/
   /*BEGIN PTS 48232 SPN*/
   , @tpr_id
   , @tpr_type
   , @tpr_ord_number
   , @tpr_payrate
   /*END PTS 48232 SPN*/
   , @ch_confirmation_received
   , @ch_id
   --PTS 55275 JJF 20110729
   , @lgh_type1
   , @lgh_type_t
   --END PTS 55275 JJF 20110729
   --BEGIN PTS 60186 SPN
   , 0 AS suggmile_fuel_charge
   --END PTS 60186 SPN
   , @lgh_number    -- PTS 66406 - DJM
  FROM carrier
 WHERE car_id = @car_id

--BEGIN PTS 60186 SPN
SELECT @ACSSuggMileFuel_YN       = IsNull(gi_string1,'N')
     , @ACSSuggMileFuel_TableID  = IsNull(gi_string2,' ')
     , @ACSSuggMileFuel_TariffNo = IsNull(gi_string3,'0')
  FROM generalinfo
 WHERE gi_name = 'ACSSuggMileFuel'
IF @ACSSuggMileFuel_YN = 'Y' AND @ACSSuggMileFuel_TableID <> ' ' AND @ACSSuggMileFuel_TariffNo <> '0'
BEGIN
   SELECT @ACSSuggMileFuel_rb = tar_rowbasis
        , @ACSSuggMileFuel_cb = tar_colbasis
     FROM tariffheaderstl
    WHERE tar_number = @ACSSuggMileFuel_TariffNo

   SELECT @ACSSuggMileFuel_afp_price = afp_price
     FROM averagefuelprice
    WHERE afp_date = (SELECT MAX(afp_date)
                        FROM averagefuelprice
                       WHERE afp_tableid = @ACSSuggMileFuel_TableID
                         AND afp_date <= @dt_GetDate
                     )
      AND afp_tableid = @ACSSuggMileFuel_TableID
   SELECT @acs_mile = lgh_miles
     FROM legheader
    WHERE lgh_number = @lgh_number

   IF NOT @ACSSuggMileFuel_afp_price IS NULL
   BEGIN
      IF @ACSSuggMileFuel_rb = 'AFP'
         INSERT INTO @t_suggmile_fuel_rate
         EXEC d_tar_gettariffrate_stl_sp @TarNum        = @ACSSuggMileFuel_TariffNo
                                       , @RowMatchValue = 'UNKNOWN'
                                       , @RowRangeValue = @ACSSuggMileFuel_afp_price
                                       , @ColMatchValue = 'UNKNOWN'
                                       , @ColRangeValue = 0
                                       , @order_first_stop_arrivaldate = @dt_GetDate
      ELSE IF @ACSSuggMileFuel_cb = 'AFP'
         INSERT INTO @t_suggmile_fuel_rate
         EXEC d_tar_gettariffrate_stl_sp @TarNum        = @ACSSuggMileFuel_TariffNo
                                       , @RowMatchValue = 'UNKNOWN'
                                       , @RowRangeValue = 0
                                       , @ColMatchValue = 'UNKNOWN'
                                       , @ColRangeValue = @ACSSuggMileFuel_afp_price
                                       , @order_first_stop_arrivaldate = @dt_GetDate
   END

   IF EXISTS (SELECT 1 FROM @t_suggmile_fuel_rate)
   BEGIN
      SELECT TOP 1
             @suggmile_fuel_rate = IsNull(tra_rate,0)
           , @tra_rateasflat     = IsNull(tra_rateasflat,'N')
           , @tra_minqty         = IsNull(tra_minqty,'N')
           , @tra_minrate        = IsNull(tra_minrate,0)
        FROM @t_suggmile_fuel_rate
      IF @tra_rateasflat = 'Y'
         SELECT @suggmile_fuel_charge = @suggmile_fuel_rate
      ELSE IF @tra_minrate <> 0
         BEGIN
            IF @tra_minqty = 'N'
               BEGIN
                  SELECT @suggmile_fuel_charge = (@acs_mile * @suggmile_fuel_rate)
                  IF @suggmile_fuel_charge < @tra_minrate
                     SELECT @suggmile_fuel_charge = @tra_minrate
               END
            ELSE
               BEGIN
                  IF @acs_mile >= @tra_minqty
                     SELECT @suggmile_fuel_charge = (@acs_mile * @suggmile_fuel_rate)
                  ELSE
                     SELECT @suggmile_fuel_charge = (@tra_minqty * @suggmile_fuel_rate)
               END
         END
      ELSE
         SELECT @suggmile_fuel_charge = (@acs_mile * @suggmile_fuel_rate)

      UPDATE #temp
         SET suggmile_fuel_charge = @suggmile_fuel_charge
   END
END
--END PTS 60186 SPN

select car_name,  -- varchar(64)
       car_contact,  -- varchar(25)
       car_phone1,   -- varchar(25)
       car_phone2,   -- varchar(25)
       car_phone3,   -- varchar(25)
       car_email, -- varchar(128)
       brk_lineHaul_charge, -- dec(12, 4)
       brk_fuel_charge,    -- dec(12, 4)
       brk_accessorial_charge,   -- dec(12, 4)
      lineHaul_charges,
      fuel_charges,
      accessorial_charges,
       total_charge,    -- dec(12,4)
       brk_lineHaul_charge_currency,   -- varchar(6)
       brk_fuel_charge_currency, -- varchar(6)
       brk_accessorial_charge_currency,      -- varchar(6)
       total_charge_currency, -- varchar(6)
       car_currency, -- varchar(6)
       car_country,     -- varchar(6)
       ord_hdr_number,  -- varchar(12)
       ord_charge_type, -- varchar(10)
       ord_quantity, -- dec(12, 4)
       ord_unit,  -- varchar(6)
       ord_line_haul,   -- dec(12, 4)
       ord_fuel_charge, -- dec(12, 4)
       ord_accessorial, -- dec(12, 4)
       ord_totalcharge, -- dec(12, 4)
       ord_line_haul_currency, -- varchar(6)
       ord_fuel_charge_currency, -- varchar(6)
       ord_accessorial_currency, -- varchar(6)
       ord_totalcharge_currency, -- varchar(6)
       car_id, -- varchar(8)
       setl_seq_alloc,  -- dec(12, 4)
       setl_pay_type,   -- int
       setl_quantity, -- dec(12, 4)
       setl_unit, -- varchar(255)
       currency_visible, -- char(1)
       payrate,  -- money
       ord_booked_revtype1, -- varchar(12)
       ord_booked_revtype1_t, -- varchar(25)
       ord_booked_revtype1_tariff,  -- int
       ord_booked_revtype1_rate, -- dec(12, 4)
       ord_booked_revtype1_amount,  -- dec(12, 4)
       lgh_booked_revtype1,      -- varchar(12)
       lgh_booked_revtype1_t, -- varchar(25)
       lgh_booked_revtype1_tariff,  -- int
       lgh_booked_revtype1_rate, -- dec(12, 4)
       lgh_booked_revtype1_amount,  -- dec(12, 4)
       lgh_carrier_truck,  -- varchar(50)
       lgh_driver_name,    -- varchar(255)
       lgh_driver_phone,   -- varchar(25)
       lgh_truck_mcnum,    -- varchar(25)
       lgh_outstatus,   -- varchar(6)
       lgh_trailernumber,  -- varchar(25)
       broker_percent,  -- decimal(8, 2)
       target_margin,   -- money
       estimated_profit,   -- money
       lgh_suggested_spend,      -- money
       lgh_top_spend,   -- money
       email_confirm,   -- tinyint
       fax_confirm,     -- tinyint
       print_confirm,   -- tinyint
       external_equipment_id, -- int
       ord_booked_revtype1_override, -- tinyint
       lgh_booked_revtype1_override,
   ch_user_id, --37106
   ch_status,  --37106
   ch_datetime,   --37106
   car_confirmpathname,
   car_204flag,
   car_confirm_type, /*PTS 46011 CGK 5/27/2009*/
   car_confirm_ir_id, /*PTS 46011 CGK 5/27/2009*/
   car_confirm_irk_id  /*PTS 46011 CGK 5/27/2009*/
     , tpr_id         --PTS 48232 SPN
     , tpr_type       --PTS 48232 SPN
     , tpr_ord_number --PTS 48232 SPN
     , tpr_payrate,    --PTS 48232 SPN
     ch_confirmation_received,
     ch_id,
   --PTS 55275 JJF 20110729
   lgh_type1,
   lgh_type1_t
   --END PTS 55275 JJF 20110729
   --BEGIN PTS 60186 SPN
   , suggmile_fuel_charge
   --END PTS 60186 SPN
   , lgh_number			-- PTS 66406 - DJM
  FROM #temp
GO
GRANT EXECUTE ON  [dbo].[d_broker_load_sp] TO [public]
GO
