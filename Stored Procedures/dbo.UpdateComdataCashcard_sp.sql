SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[UpdateComdataCashcard_sp] 

@ls_cardnumber 			varchar(10),
@ls_status 			varchar(1),	
@ls_employee_number 		varchar(10),
@ls_driver_name 		varchar(20),
@ls_unit_number 		varchar(6),
@ls_trip_number 		varchar(10),
@ls_drv_license_num	 	varchar(20),
@ls_drv_license_state 		varchar(2),
@ls_limit_network_by_card 	varchar(1),
@ls_company_standards_flag 	varchar(1),
@ls_drv_first_name 		varchar(15),
@ls_drv_last_name 		varchar(20),
@ls_cash_renew_daily 		varchar(1),
@ls_cash_renew_mon 		varchar(1),
@ls_cash_renew_tue 		varchar(1),
@ls_cash_renew_wed 		varchar(1),
@ls_cash_renew_thu 		varchar(1),
@ls_cash_renew_fri 		varchar(1),
@ls_cash_renew_sat 		varchar(1),
@ls_cash_renew_sun 		varchar(1),
@ls_cash_renew_trip 		varchar(1),
@ls_purchase_renew_daily 	varchar(1),
@ls_purchase_renew_mon 		varchar(1),
@ls_purchase_renew_tue 		varchar(1),
@ls_purchase_renew_wed 		varchar(1),
@ls_purchase_renew_thu 		varchar(1),
@ls_purchase_renew_fri 		varchar(1),
@ls_purchase_renew_sat 		varchar(1),
@ls_purchase_renew_sun 		varchar(1),
@ls_purchase_renew_trip 	varchar(1),
@ls_trailer_number 		varchar(10),
@ls_fuel_purchase_flag 		varchar(1),
@ls_express_cash_flag 		varchar(1),
@ls_phone_service 		varchar(1),
@ls_phone_renew_daily 		varchar(1),
@ls_phone_renew_mon 		varchar(1),
@ls_phone_renew_tue 		varchar(1),
@ls_phone_renew_wed 		varchar(1),
@ls_phone_renew_thu 		varchar(1),
@ls_phone_renew_fri 		varchar(1),
@ls_phone_renew_sat 		varchar(1),
@ls_phone_renew_sun 		varchar(1),
@ls_phone_renew_trip 		varchar(1),
@ls_atm_access_flag 		varchar(1),
@ls_oil_renew_daily 		varchar(1),
@ls_oil_renew_mon 		varchar(1),
@ls_oil_renew_tue 		varchar(1),
@ls_oil_renew_wed 		varchar(1),
@ls_oil_renew_thu 		varchar(1),
@ls_oil_renew_fri 		varchar(1),
@ls_oil_renew_sat 		varchar(1),
@ls_oil_renew_sun 		varchar(1),
@ls_oil_renew_trip	 	varchar(1),
@ls_onetime_fuel_off_network 	varchar(1),
@ls_voicemail_flag 		varchar(1),
@ls_faxmail_flag 		varchar(1),
@ls_conference_call_flag 	varchar(1),
@ls_message_srvc_flag 		varchar(1),
@ls_info_srvc_flag 		varchar(1),
@ls_vru_access_flag 		varchar(1),
-----Need to convert-----
@ls_card_balance 		varchar(9),
@ls_cash_limit 			varchar(9),
@ls_cash_used 			varchar(9),
@ls_cash_onetime 		varchar(9),
@ls_purchase_limit 		varchar(9),
@ls_purchase_used 		varchar(9),
@ls_purchase_onetime 		varchar(9),
@ls_diesel_gallon_limit 	varchar(6),
@ls_reefer_gallon_limit 	varchar(6),
@ls_phone_limit			varchar(9),
@ls_phone_used 			varchar(9),
@ls_oil_dollar_limit 		varchar(9),
@ls_oil_quart_limit 		varchar(4),
@ls_oil_dollars_used 		varchar(9),
@ls_oil_quarts_used 		varchar(4),
-----Need to convert-----
@ls_accountid			varchar(10),
@ls_customerid			varchar(10)

AS
--DPH PTS 30225 - Accounting for implicit decimals
DECLARE @lm_purchase_limit	money,
	@lm_purchase_onetime	money,
	@lm_cash_limit		money,
	@lm_cash_onetime	money,
	@lm_phone_limit		money,
	@lm_oil_dollar_limit	money,
	@lm_card_balance	money,
	@ComdataIUpdatesDRVInfo		varchar(30),
	@ls_asgn_type				varchar(6),
	@ls_asgn_id					varchar(13),
	@ls_driver					varchar(8)

SELECT	@lm_purchase_limit = convert(money, @ls_purchase_limit), 
	@lm_purchase_onetime = convert(money, @ls_purchase_onetime),
	@lm_cash_limit = convert(money, @ls_cash_limit),
	@lm_cash_onetime = convert(money, @ls_cash_onetime),
	@lm_phone_limit = convert(money, @ls_phone_limit),
	@lm_oil_dollar_limit = convert(money,  @ls_oil_dollar_limit),
	@lm_card_balance = convert(money, @ls_card_balance)
	

SELECT	@lm_purchase_limit = @lm_purchase_limit/100,
	@lm_purchase_onetime = @lm_purchase_onetime/100,
	@lm_cash_limit = @lm_cash_limit/100,
	@lm_cash_onetime = @lm_cash_onetime/100,
	@lm_phone_limit = @lm_phone_limit/100,
	@lm_oil_dollar_limit = @lm_oil_dollar_limit/100,
	@lm_card_balance = @lm_card_balance/100
--DPH PTS 30225 - Accounting for implicit decimals

--Convert to numeric
If @ls_fuel_purchase_flag = 'N' Select @ls_fuel_purchase_flag = '0'
If @ls_fuel_purchase_flag = 'Y' Select @ls_fuel_purchase_flag = '1'
If @ls_express_cash_flag = 'N' Select @ls_express_cash_flag = '0'
If @ls_express_cash_flag = 'Y' Select @ls_express_cash_flag = '1'
If @ls_onetime_fuel_off_network = 'N' Select @ls_onetime_fuel_off_network = '0' --JLB PTS 44989
If @ls_onetime_fuel_off_network = 'Y' Select @ls_onetime_fuel_off_network = '1' --JLB PTS 44989
--Convert to numeric

--Avoid inserting blank fields - default to '0'
If @ls_limit_network_by_card = ' ' Select @ls_limit_network_by_card = '0'
If @ls_cash_renew_daily = ' ' Select @ls_cash_renew_daily = '0'
If @ls_cash_renew_mon = ' ' Select @ls_cash_renew_mon = '0'
If @ls_cash_renew_tue = ' ' Select @ls_cash_renew_tue = '0'
If @ls_cash_renew_wed = ' ' Select @ls_cash_renew_wed = '0'
If @ls_cash_renew_thu = ' ' Select @ls_cash_renew_thu = '0'
If @ls_cash_renew_fri = ' ' Select @ls_cash_renew_fri = '0'
If @ls_cash_renew_sat = ' ' Select @ls_cash_renew_sat = '0'
If @ls_cash_renew_sun = ' ' Select @ls_cash_renew_sun = '0'
If @ls_cash_renew_trip = ' ' Select @ls_cash_renew_trip = '0'
If @ls_purchase_renew_daily = ' ' Select @ls_purchase_renew_daily = '0'
If @ls_purchase_renew_mon = ' ' Select @ls_purchase_renew_mon = '0'
If @ls_purchase_renew_tue = ' ' Select @ls_purchase_renew_tue = '0'
If @ls_purchase_renew_wed = ' ' Select @ls_purchase_renew_wed = '0'
If @ls_purchase_renew_thu = ' ' Select @ls_purchase_renew_thu = '0'
If @ls_purchase_renew_fri = ' ' Select @ls_purchase_renew_fri = '0'
If @ls_purchase_renew_sat = ' ' Select @ls_purchase_renew_sat = '0'
If @ls_purchase_renew_sun = ' ' Select @ls_purchase_renew_sun = '0'
If @ls_purchase_renew_trip = ' ' Select @ls_purchase_renew_trip = '0'
If @ls_trailer_number = ' ' Select @ls_trailer_number = '0'
If @ls_fuel_purchase_flag = ' ' Select @ls_fuel_purchase_flag = '0'
If @ls_express_cash_flag = ' ' Select @ls_express_cash_flag = '0'
If @ls_phone_service = ' ' Select @ls_phone_service = '0'
If @ls_phone_renew_daily = ' ' Select @ls_phone_renew_daily = '0'
If @ls_phone_renew_mon = ' ' Select @ls_phone_renew_mon = '0'
If @ls_phone_renew_tue = ' ' Select @ls_phone_renew_tue = '0'
If @ls_phone_renew_wed = ' ' Select @ls_phone_renew_wed = '0'
If @ls_phone_renew_thu = ' ' Select @ls_phone_renew_thu = '0'
If @ls_phone_renew_fri = ' ' Select @ls_phone_renew_fri = '0'
If @ls_phone_renew_sat = ' ' Select @ls_phone_renew_sat = '0'
If @ls_phone_renew_sun = ' ' Select @ls_phone_renew_sun = '0'
If @ls_phone_renew_trip = ' ' Select @ls_phone_renew_trip = '0'
If @ls_atm_access_flag = ' ' Select @ls_atm_access_flag = 'N'
If @ls_oil_renew_daily = ' ' Select @ls_oil_renew_daily = '0'
If @ls_oil_renew_mon = ' ' Select @ls_oil_renew_mon = '0'
If @ls_oil_renew_tue = ' ' Select @ls_oil_renew_tue = '0'
If @ls_oil_renew_wed = ' ' Select @ls_oil_renew_wed = '0'
If @ls_oil_renew_thu = ' ' Select @ls_oil_renew_thu = '0'
If @ls_oil_renew_fri = ' ' Select @ls_oil_renew_fri = '0'
If @ls_oil_renew_sat = ' ' Select @ls_oil_renew_sat = '0'
If @ls_oil_renew_sun = ' ' Select @ls_oil_renew_sun = '0'
If @ls_oil_renew_trip = ' ' Select @ls_oil_renew_trip = '0'
If @ls_onetime_fuel_off_network = ' ' Select @ls_onetime_fuel_off_network = '0'
If @ls_voicemail_flag = ' ' Select @ls_voicemail_flag = '0'
If @ls_faxmail_flag = ' ' Select @ls_faxmail_flag = '0'
If @ls_conference_call_flag = ' ' Select @ls_conference_call_flag = '0'
If @ls_message_srvc_flag = ' ' Select @ls_message_srvc_flag = '0'
If @ls_info_srvc_flag = ' ' Select @ls_info_srvc_flag = '0'
If @ls_vru_access_flag = ' ' Select @ls_vru_access_flag = '0'
--Avoid inserting blank fields - default to '0'

--Remap ATM Flag
--If	@ls_atm_access_flag = 'C' or @ls_atm_access_flag = 'E' or @ls_atm_access_flag = 'B' or @ls_atm_access_flag = '1'
-- BEGIN	
--	SELECT @ls_atm_access_flag = 'Y'
-- END
--Remap ATM Flag

select	@ls_accountid = rtrim(@ls_accountid),
		@ls_customerid = rtrim(@ls_customerid),
		@ls_cardnumber = rtrim(@ls_cardnumber)
		
--JLB PTS 50817  if the GI setting is off then get the original values and use those not the values from Comdata
select @ls_asgn_type = 'DRV'
select @ComdataIUpdatesDRVInfo = gi_string1
  from generalinfo
  where gi_name = 'ComdataIUpdatesDRVInfo'
if @ComdataIUpdatesDRVInfo = 'N'
begin
select @ls_asgn_type = asgn_type,
       @ls_asgn_id = asgn_id,
       @ls_drv_first_name = crd_firstname,
	   @ls_drv_last_name = crd_lastname,
 	   @ls_drv_license_num = crd_driverlicensenum,
	   @ls_drv_license_state = crd_driverlicensestate ,
	   @ls_unit_number = crd_unitnumber,
 	   @ls_driver = crd_driver
  from cashcard
 where crd_cardnumber = @ls_cardnumber
   and crd_accountid = @ls_accountid
   and crd_customerid = @ls_customerid
end
--end 50817
		
--Update Comdata Cashcard
Update 	cashcard 
set 	crd_status = @ls_status, 			
	crd_atmaccess = @ls_atm_access_flag, 
	crd_vruaccess = @ls_vru_access_flag, 
	crd_limitnetworkbycard = @ls_limit_network_by_card,
 	asgn_type = @ls_asgn_type, 
	asgn_id = isnull(@ls_asgn_id, @ls_employee_number), 
	crd_firstname = @ls_drv_first_name, 
	crd_lastname = @ls_drv_last_name, 
 	crd_driverlicensenum = @ls_drv_license_num, 
	crd_driverlicensestate = @ls_drv_license_state, 
	crd_unitnumber = RTRIM(LTRIM(@ls_unit_number)),	
 	crd_driver = isnull(@ls_driver, @ls_employee_number), 
	crd_trailernumber = @ls_trailer_number, 
	crd_tripnumber = @ls_trip_number, 
	crd_fuelpurchaseyn = @ls_fuel_purchase_flag,			
 	crd_purchaselimit = @lm_purchase_limit, 
	crd_onetimepurchaselimit = @lm_purchase_onetime, 
	crd_diesellimit = convert(int, @ls_diesel_gallon_limit), 
	crd_reeferlimit = convert(int,@ls_reefer_gallon_limit),
 	crd_purchrenewdaily = @ls_purchase_renew_daily, 
	crd_purchrenewmon = @ls_purchase_renew_mon, 
	crd_purchrenewtue = @ls_purchase_renew_tue, 
	crd_purchrenewwed = @ls_purchase_renew_wed,	
 	crd_purchrenewthu = @ls_purchase_renew_thu, 
	crd_purchrenewfri = @ls_purchase_renew_fri, 
	crd_purchrenewsat = @ls_purchase_renew_sat, 
	crd_purchrenewsun = @ls_purchase_renew_sun,	
 	crd_purchrenewtrip = @ls_purchase_renew_trip, 
	crd_expcashflagyn = @ls_express_cash_flag, 
	crd_cashlimit = @lm_cash_limit,
	crd_onetimecashlimit = @lm_cash_onetime,
 	crd_cashbalance = @lm_card_balance,
	crd_cashrenewdaily = @ls_cash_renew_daily, 
	crd_cashrenewmon = @ls_cash_renew_mon, 
	crd_cashrenewtue = @ls_cash_renew_tue,		
 	crd_cashrenewwed = @ls_cash_renew_wed, 
	crd_cashrenewthu = @ls_cash_renew_thu, 
	crd_cashrenewfri = @ls_cash_renew_fri, 
	crd_cashrenewsat = @ls_cash_renew_sat,		
 	crd_cashrenewsun = @ls_cash_renew_sun, 
	crd_cashrenewtrip = @ls_cash_renew_trip, 
	crd_phoneamountlimit = @lm_phone_limit,
 	crd_phonerenewdaily = @ls_phone_renew_daily, 
	crd_phonerenewsun = @ls_phone_renew_sun,
 	crd_phonerenewmon = @ls_phone_renew_mon, 
	crd_phonerenewtue = @ls_phone_renew_tue,	
 	crd_phonerenewwed = @ls_phone_renew_wed, 
	crd_phonerenewthu = @ls_phone_renew_thu, 
	crd_phonerenewfri = @ls_phone_renew_fri, 
	crd_phonerenewsat = @ls_phone_renew_sat,	
 	crd_phonerenewtrip = @ls_phone_renew_trip, 
	crd_oilamountlimit = @lm_oil_dollar_limit,
	crd_oillimit = convert(int, @ls_oil_quart_limit),
	crd_oilrenewdaily = @ls_oil_renew_daily,		
 	crd_oilrenewsun = @ls_oil_renew_sun, 
	crd_oilrenewmon = @ls_oil_renew_mon, 
	crd_oilrenewtue = @ls_oil_renew_tue, 
	crd_oilrenewwed = @ls_oil_renew_wed,		
 	crd_oilrenewthu = @ls_oil_renew_thu,
 	crd_oilrenewfri = @ls_oil_renew_fri, 
	crd_oilrenewsat = @ls_oil_renew_sat, 
	crd_oilrenewtrip = @ls_oil_renew_trip,
	crd_onetimefuel_off = @ls_onetime_fuel_off_network --JLB PTS 44989
where 	crd_cardnumber = @ls_cardnumber
  and	crd_accountid = @ls_accountid
  and	crd_customerid = @ls_customerid
--Update Comdata Cashcard

--Set values back to 'N' to counter trigger
update 	cashcard
set	crd_purchrenewdaily_old = 'N',
	crd_purchrenewtrip_old = 'N',
	crd_cashrenewdaily_old = 'N',
	crd_cashrenewtrip_old = 'N',
	crd_phonerenewdaily_old = 'N',
	crd_phonerenewtrip_old = 'N',
	crd_oilrenewdaily_old = 'N',
	crd_oilrenewtrip_old = 'N'
where	crd_cardnumber = @ls_cardnumber
  and	crd_accountid = @ls_accountid
  and	crd_customerid = @ls_customerid
--Set values back to 'N' to counter trigger
GO
GRANT EXECUTE ON  [dbo].[UpdateComdataCashcard_sp] TO [public]
GO
