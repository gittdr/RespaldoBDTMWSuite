SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--Drop proc WORD_InterfaceEXAMPLE_JR

--exec WORD_InterfaceEXAMPLE_JR 111213


CREATE proc [dbo].[WORD_InterfaceEXAMPLE_JR]
		@lgh_number int
as
/*************************



*************************/
--fuel

Declare @PermitPayBasis varchar(10)
Declare @stopPayBasis varchar(10)
Declare @FuelPayBasis varchar(10)
Declare @BrokerageNotes varchar(254)
Declare @ModifiedBy varchar(128)

select @PermitPayBasis ='WHATISPERMIT' -- CHANGE THIS TO USE PERMIT PAY
select @stopPayBasis ='STOP'

--33184 BDH (from 34262)
--Select @FuelPayBasis ='BRKFUL'  --08/22/06 changed by mrk
select @FuelPayBasis = isNull(gi_string1,'BRKFUL') from generalinfo where gi_name = 'ACSFuelPayType'


Declare @TotalPieces float
Declare @TotalWeight float
declare @TotalLineHaulPay money
declare @LineHaulPayCurrency varchar(10)
declare @StopPay money
declare @TotalPay money
Declare @ordhdrNumber int
Declare @Mov_Number int
declare @PermitPay money
declare @FuelPay money
declare @FuelPayCurrency varchar(10)
declare @LegCount int
declare @OtherPayCurrency varchar(10)

declare @Pup_stp_comment varchar(254)
declare @Drp_stp_comment varchar(254)

declare @stp_comment varchar (254)
declare @pickupNum varchar(30)

-- PTS 32651 - DJM
Declare @contact	varchar(254),
	@contact_phone	varchar(20),
	@loadreq_exist		varchar(3),
	@contact_name	varchar(254)

-- declaracion de tablas temporales JR

DECLARE @Tnormal TABLE(
ORD_SHIPPER Varchar(8),
ORD_CONSIGNEE Varchar(8),
shipper_CMP_NAME Varchar(100),
shipper_cmp_address1  Varchar(100),
shipper_cmp_address2  Varchar(100),
shipper_cty_nmstct Varchar(18),
shipper_cty_nmstctFULL Varchar(25),
shipper_cmp_zip  Varchar(10),
shipper_cmp_primaryphone  Varchar(20),
Consignee_CMP_NAME Varchar(100),
Consignee_cmp_address1 Varchar(100),
Consignee_cmp_address2 Varchar(100),
Consignee_cty_nmstct Varchar(20),
Consignee_cty_nmstctFULL Varchar(25),
Consignee_cmp_zip Varchar(10),
Consignee_cmp_primaryphone  Varchar(20))

DECLARE @TSplit TABLE(
shipper_CMP_NAME Varchar(100),
shipper_cmp_address1 Varchar(100),
shipper_cmp_address2 Varchar(100),
shipper_cty_nmstct Varchar(30),
shipper_cty_nmstctFULL Varchar(50),
shipper_cmp_zip Varchar(10),
shipper_cmp_primaryphone Varchar(20),
Consignee_CMP_NAME Varchar(100),
Consignee_cmp_address1 Varchar(100),
Consignee_cmp_address2 Varchar(100),
Consignee_cty_nmstct Varchar(30),
Consignee_cty_nmstctFULL Varchar(50),	
Consignee_cmp_zip Varchar(10),
Consignee_cmp_primaryphone Varchar(20))

DECLARE @TOrder TABLE(
	lgh_number int,
  	mov_number int,
    	lgh_driver1 varchar(8),
    	lgh_tractor varchar(8),
	lgh_carrier varchar(8),
	ord_number  varchar(254),
	ord_remark varchar(254),
    	ord_company varchar(8),
	ord_customer varchar(8),
	ord_bookdate datetime,               
	ord_bookedby char(20) ,       
	ord_status  varchar(6),
	ord_originpoint varchar(8),
	ord_destpoint varchar(8),
	ord_origincity int,
	ord_destcity int,
	ord_originstate  varchar(6),
	ord_deststate varchar(6),
	ord_supplier varchar(8),
	ord_billto varchar(8),
	ord_startdate datetime,
	ord_completiondate datetime,
	ord_revtype1 varchar(20),
	ord_revtype2 varchar(20),
	ord_revtype3 varchar(20),
	ord_revtype4 varchar(20),
	ord_totalweight varchar(6) ,
	ord_totalpieces decimal(9,4) ,
	ord_totalmiles  Int,
	ord_totalcharge float,        
	ord_currency varchar(6),
	ord_currencydate datetime,
	ord_totalvolume float,
	ord_hdrnumber int,
	ord_refnum varchar(30),
	ord_invoicewhole char(1),
	ord_shipper varchar(8),
	ord_consignee varchar(8),
	ord_pu_at varchar(6),
	ord_dr_at varchar(6),
	ord_contact varchar(30),                  
	ord_lowtemp tinyint,
	ord_hitemp tinyint,
	ord_quantity float,            
	ord_rate money,             
	ord_charge money,            
	ord_rateunit varchar(6),
	ord_unit varchar(6),
	trl_type1 varchar(6),
	ord_driver1 varchar(8),
	ord_driver2 varchar(8),
	ord_tractor varchar(8),
	ord_trailer varchar(13),
	trl_type1_desc varchar(20), 
	ord_length money,             
	ord_width money,            
	ord_height money,           
	ord_lengthunit varchar(6),
	ord_widthunit varchar(6),
	ord_heightunit varchar(6),
	ord_reftype varchar(6),
	cmd_code varchar(8),
	cmd_name varchar(60),
	ord_description  varchar(60),
	cht_itemcode varchar(6),
	ord_origin_earliestdate datetime,
	ord_origin_latestdate datetime,
	ord_stopcount tinyint,
	ord_dest_earliestdate datetime,
	ord_dest_latestdate datetime,
	ord_cmdvalue money,
	ord_accessorial_chrg money,
	ord_availabledate datetime,
	ord_miscqty decimal(9,2),
	ord_tempunits varchar(6),
	ord_datetaken datetime ,            
	ord_totalweightunits varchar(6),
	ord_totalvolumeunits varchar(6),
	ord_totalcountunits varchar(6),
	ord_rateby char(1),
	ord_quantity_type int ,
	TotalPieces decimal(9,4),
	TotalWeight float,
	TotalLineHaulPay money,
	TotalPay money,
	StopPay money,
	PermitPay money,
	FuelPay money,
	PupStpComment  varchar(254),
	DrpStpComment  varchar(254),
	ModifiedBy  varchar(128),
	carrier_payrate money,
	pyd_description varchar(75))


DECLARE @TPay TABLE(
lgh_number int,
mov_number int,
lgh_driver1 varchar(8),
lgh_tractor varchar(8),
lgh_carrier varchar(8),
ord_number  varchar(254),
ord_remark varchar(254),
ord_company varchar(8),
ord_customer varchar(8),
ord_bookdate datetime,               
ord_bookedby char(20) ,       
ord_status  varchar(6),
ord_originpoint varchar(8),
ord_destpoint varchar(8),
ord_origincity int,
ord_destcity int,
ord_originstate  varchar(6),
ord_deststate varchar(6),
ord_supplier varchar(8),
ord_billto varchar(8),
ord_startdate datetime,
ord_completiondate datetime,
ord_revtype1 varchar(20),
ord_revtype2 varchar(20),
ord_revtype3 varchar(20),
ord_revtype4 varchar(20),
ord_totalweight varchar(6) ,
ord_totalpieces decimal(9,2) ,
ord_totalmiles  Int,
ord_totalcharge float,        
ord_currency varchar(6),
ord_currencydate datetime,
ord_totalvolume float,
ord_hdrnumber int,
ord_refnum varchar(30),
ord_invoicewhole char(1),
ord_shipper varchar(8),
ord_consignee varchar(8),
ord_pu_at varchar(6),
ord_dr_at varchar(6),
ord_contact varchar(30),                  
ord_lowtemp tinyint,
ord_hitemp tinyint,
ord_quantity float,            
ord_rate money,             
ord_charge money,            
ord_rateunit varchar(6),
ord_unit varchar(6),
trl_type1 varchar(6),
ord_driver1 varchar(8),
ord_driver2 varchar(8),
ord_tractor varchar(8),
ord_trailer varchar(13),
trl_type1_desc varchar(20), 
ord_length money,             
ord_width money,            
ord_height money,           
ord_lengthunit varchar(6),
ord_widthunit varchar(6),
ord_heightunit varchar(6),
ord_reftype varchar(6),
cmd_code varchar(8),
cmd_name varchar(60),
ord_description  varchar(60),
cht_itemcode varchar(6),
ord_origin_earliestdate datetime,
ord_origin_latestdate datetime,
ord_stopcount tinyint,
ord_dest_earliestdate datetime,
ord_dest_latestdate datetime,
ord_cmdvalue money,
ord_accessorial_chrg money,
ord_availabledate datetime,
ord_miscqty decimal(9,2),
ord_tempunits varchar(6),
ord_datetaken datetime ,            
ord_totalweightunits varchar(6),
ord_totalvolumeunits varchar(6),
ord_totalcountunits varchar(6),
ord_rateby char(1),
ord_quantity_type int ,
TotalPieces decimal(9,2),
TotalWeight float,
TotalLineHaulPay money,
TotalPay money,
StopPay money,
PermitPay money,
FuelPay money,
PupStpComment  varchar(254),
DrpStpComment  varchar(254),
ModifiedBy  varchar(128),
carrier_payrate money,
pyd_description varchar(75),
OtherPay money)

DECLARE @TCarrier TABLE(
lgh_number int,
lgh_carrier varchar(8),
ord_number  varchar(254),
ord_remark varchar(254),
ord_company varchar(8),
ord_customer varchar(8),
ord_bookdate datetime,               
ord_bookedby char(20) ,       
ord_status  varchar(6),
ord_originpoint varchar(8),
ord_destpoint varchar(8),
ord_origincity int,
ord_destcity int,
ord_originstate  varchar(6),
ord_deststate varchar(6),
ord_supplier varchar(8),
ord_billto varchar(8),
ord_startdate datetime,
ord_completiondate datetime,
ord_revtype1 varchar(20),
ord_revtype2 varchar(20),
ord_revtype3 varchar(20),
ord_revtype4 varchar(20),
ord_totalweight varchar(6) ,
ord_totalpieces decimal(9,2) ,
ord_totalmiles  Int,
ord_totalcharge float,        
ord_currency varchar(6),
ord_currencydate datetime,
ord_totalvolume float,
ord_hdrnumber int,
ord_refnum varchar(30),
ord_invoicewhole char(1),
ord_shipper varchar(8),
ord_consignee varchar(8),
ord_pu_at varchar(6),
ord_dr_at varchar(6),
ord_contact varchar(30),                  
ord_lowtemp tinyint,
ord_hitemp tinyint,
ord_quantity float,            
ord_rate money,             
ord_charge money,            
ord_rateunit varchar(6),
ord_unit varchar(6),
trl_type1 varchar(6),
ord_driver1 varchar(8),
ord_driver2 varchar(8),
ord_tractor varchar(8),
ord_trailer varchar(13),
trl_type1_desc varchar(20), 
ord_length money,             
ord_width money,            
ord_height money,           
ord_lengthunit varchar(6),
ord_widthunit varchar(6),
ord_heightunit varchar(6),
ord_reftype varchar(6),
cmd_code varchar(8),
cmd_name varchar(60),
ord_description  varchar(60),
cht_itemcode varchar(6),
ord_origin_earliestdate datetime,
ord_origin_latestdate datetime,
ord_stopcount tinyint,
ord_dest_earliestdate datetime,
ord_dest_latestdate datetime,
ord_cmdvalue money,
ord_accessorial_chrg money,
ord_availabledate datetime,
ord_miscqty decimal(9,4),
ord_tempunits varchar(6),
ord_datetaken datetime ,            
ord_totalweightunits varchar(6),
ord_totalvolumeunits varchar(6),
ord_totalcountunits varchar(6),
ord_rateby char(1),
ord_quantity_type int ,
TotalPieces decimal(9,4),
TotalWeight float,
TotalLineHaulPay money,
TotalPay money,
StopPay money,
PermitPay money,
FuelPay money,
PupStpComment  varchar(254),
DrpStpComment  varchar(254),
ModifiedBy  varchar(128),
pyd_description varchar(75),
OtherPay money,
Ord_RefNum2 varchar(30),
car_name varchar(64),
Car_id varchar(8),
car_phone1 char(10),
car_phone2 char(10),
car_phone3 char(10),
car_fedid varchar(10),
car_scac char(4),
car_contact varchar(25),
car_type1 char(6),
car_type2 char(6),
car_type3 char(6),
car_type4 char(6),
car_misc1 varchar(450),
car_misc2 varchar(450),
car_misc3 varchar(450),
car_misc4 varchar(450),
car_actg_type varchar(6),
car_iccnum varchar(12),
car_contract varchar(20),
car_otherid varchar(8),
car_usecashcard char(1),
car_status varchar(6),
car_board char(1))

--Continuacion JR

SELECT @Mov_Number  =
	(SELECT
		Mov_number 
	from 
		legheader 
	where 
		lgh_number = @lgh_number)

SELECT @BrokerageNotes = 
	(SELECT not_text
	from Notes
	where ntb_table = 'movement' and nre_tablekey = @mov_number)

SELECT @ordhdrNumber = 
	(SELECT
		min(ord_hdrnumber) 
	from 
		legheader 
	where 
		lgh_number = @lgh_number)

-- 33207
select @stp_comment = isnull((select stp_comment		
			from stops
			where stp_type = 'PUP'
			and ord_hdrnumber = @ordhdrNumber
			and stp_sequence = (select min(stp_sequence)
						from stops
						where stp_type = 'PUP'
						and ord_hdrnumber = @ordhdrNumber))
			,'')

select @PickupNum = isnull((select ref_number	
			from referencenumber
			where ord_hdrnumber = @ordhdrNumber
			and ref_type = 'PU#'
			and ref_sequence = (select min(ref_sequence)
						from referencenumber
						where ord_hdrnumber = @ordhdrNumber
						and ref_type = 'PU#'))
		, '')
--end 33207

SELECT @ModifiedBy = (Select lgh_updatedby from legheader where lgh_number = @lgh_number)

select @TotalPieces =
    ( Select sum(stp_count)
        FROM
         stops
        WHERE stops.ord_hdrnumber = @ordhdrNumber
            and stp_type='DRP')


SELECT @TotalWeight =
    ( Select sum(stp_weight)
        FROM
         stops
        WHERE stops.ord_hdrnumber = @ordhdrNumber
            and stp_type='DRP')

SELECT @Pup_stp_comment = (Select stp_comment FROM stops WHERE stops.ord_hdrnumber = @ordhdrNumber 
		and stp_mfh_sequence = (select min(stp_mfh_sequence) from stops where stops.ord_hdrnumber = @ordhdrNumber and stp_type='PUP'))

SELECT @Drp_stp_comment = (Select stp_comment FROM stops WHERE stops.ord_hdrnumber = @ordhdrNumber 
		and stp_mfh_sequence = (select max(stp_mfh_sequence) from stops where stops.ord_hdrnumber = @ordhdrNumber and stp_type='DRP'))


SELECT @LineHaulPayCurrency =
    ISNULL(	
    ( Select ISNULL(Max(ISNULL(pyd_currency,'')), '')
        FROM
            paydetail,
            paytype
         WHERE
            Paydetail.lgh_number = @lgh_number
            and paytype.pyt_itemcode=Paydetail.pyt_itemcode
            and pyt_basis='LGH' )
     ,0)

SELECT @TotalLineHaulPay =
    ISNULL(	
    ( Select Sum(ISNULL(pyd_amount,0))
        FROM
            paydetail,
            paytype
         WHERE
            Paydetail.lgh_number = @lgh_number
            and paytype.pyt_itemcode=Paydetail.pyt_itemcode
            and pyt_basis='LGH' )
     ,0)	

SELECT @TotalPay =
    ISNULL(	
    ( Select Sum(ISNULL(pyd_amount,0))
        FROM
            paydetail
         WHERE
            Paydetail.lgh_number = @lgh_number
            )
    ,0)	

SELECT @StopPay =
    ISNULL(  	
    ( Select Sum(ISNULL(pyd_amount,0))
        FROM
            paydetail,
            paytype
         WHERE
            Paydetail.lgh_number = @lgh_number
            and paytype.pyt_itemcode=Paydetail.pyt_itemcode
            and pyt_basis=@stopPayBasis )
     ,0)
SELECT @PermitPay =
    ISNULL(  	
        ( Select Sum(ISNULL(pyd_amount,0))
            FROM
                paydetail,
                paytype
		
            WHERE
                Paydetail.lgh_number=@Lgh_number
            AND
                paytype.pyt_itemcode = Paydetail.pyt_itemcode
            AND
                pyt_basis=@PermitPayBasis )
     ,0)
SELECT @FuelPay =
	ISNULL(
        ( Select Sum(ISNULL(pyd_amount,0))
            FROM
                paydetail
		
            WHERE
                Paydetail.lgh_number=@Lgh_number
            AND
                @FuelPayBasis = Paydetail.pyt_itemcode
	)
	,0)
SELECT @FuelPayCurrency =
	ISNULL(
        ( Select ISNULL(Max(ISNULL(pyd_currency,'')), '')
            FROM
                paydetail
		
            WHERE
                Paydetail.lgh_number=@Lgh_number
            AND
                @FuelPayBasis = Paydetail.pyt_itemcode
	)
	,0)
SELECT @OtherPayCurrency =
	ISNULL(
        ( Select ISNULL(Max(ISNULL(pyd_currency,'')), '')
            FROM
                paydetail, paytype
		
            WHERE
                Paydetail.lgh_number=@Lgh_number
			AND
				paydetail.pyt_itemcode = paytype.pyt_itemcode
            AND
                @FuelPayBasis <> Paydetail.pyt_itemcode
			AND
				paytype.pyt_basis <> 'LGH'
	)
	,0)

--PTS 32651 - DJM - Added to get the current User.
exec gettmwuser @contact output

-- PTS 32651 - DJM
Declare @loadrq	varchar(6)
select @loadrq = isNull(gi_string1,'') from generalinfo where gi_name = 'LoadBrokerConfirmLQtype'

select @contact_name = isNull(usr_fname,'') + ' ' + isNull(usr_lname,'') from ttsusers where isNull(usr_windows_userid,usr_userid) = @contact
select @contact_phone = usr_contact_number from ttsusers where isNull(usr_windows_userid,usr_userid) = @contact
select @loadreq_exist = isnull((select 'YES' 
					from loadrequirement l 
					where l.mov_number = @mov_number 
						and l.lrq_type = @loadrq
						and l.lrq_equip_type = 'TRL'
						and lrq_manditory = 'Y'),'NO')



--- Split trip support.....
select @LegCount = (Select count(lgh_number) from legheader where mov_number = @Mov_number)

-- Testing for unknown city information
select @LegCount = 2

if @LegCount = 1
begin	--NON split trip
INSERT INTO	@Tnormal
	SELECT
	orderheader.ORD_SHIPPER,
	orderheader.ORD_CONSIGNEE,
	C1.CMP_NAME shipper_CMP_NAME,
	C1.cmp_address1     shipper_cmp_address1,
	C1.cmp_address2     shipper_cmp_address2,
	cty1.cty_nmstct     shipper_cty_nmstct,
	rtrim(cty1.cty_name)+', '+ cty1.cty_state    shipper_cty_nmstctFULL,	
	C1.cmp_zip          shipper_cmp_zip,
	C1.cmp_primaryphone     shipper_cmp_primaryphone,

	C2.CMP_NAME         Consignee_CMP_NAME ,
	C2.cmp_address1     Consignee_cmp_address1,
	C2.cmp_address2     Consignee_cmp_address2,
	cty2.cty_nmstct     Consignee_cty_nmstct,
	rtrim(cty2.cty_name)+', '+ cty2.cty_state    Consignee_cty_nmstctFULL,	
	C2.cmp_zip          Consignee_cmp_zip,
	C2.cmp_primaryphone     Consignee_cmp_primaryphone
    from 
	orderheader,
	company AS C1,
	company AS C2,
	city as cty1,
	city as cty2
    where
	orderheader.mov_number = @mov_number
	and
	C1.CMP_ID = orderheader.ORD_SHIPPER
	AND
	C2.CMP_ID = orderheader.ORD_CONSIGNEE
	and
	cty1.cty_code = C1.cmp_city
	and
	cty2.cty_code = C2.cmp_city

end
else
begin 	--- Split trip support

INSERT INTO   @Tsplit
SELECT
	company.CMP_NAME        shipper_CMP_NAME ,
	company.cmp_address1     shipper_cmp_address1,
	company.cmp_address2     shipper_cmp_address2,
	city.cty_nmstct     shipper_cty_nmstct,
	rtrim(city.cty_name)+', '+ city.cty_state    shipper_cty_nmstctFULL,	
	company.cmp_zip          shipper_cmp_zip,
	company.cmp_primaryphone     shipper_cmp_primaryphone,
	C2.CMP_NAME         Consignee_CMP_NAME ,
	C2.cmp_address1     Consignee_cmp_address1,
	C2.cmp_address2     Consignee_cmp_address2,
	cty2.cty_nmstct     Consignee_cty_nmstct,
	rtrim(cty2.cty_name)+', '+ cty2.cty_state  Consignee_cty_nmstctFULL,	
	C2.cmp_zip          Consignee_cmp_zip,
	C2.cmp_primaryphone     Consignee_cmp_primaryphone
    from
	company,
	city,
	company AS C2,
	city as cty2

    where
	company.CMP_ID = (select cmp_id from stops where lgh_number = @lgh_number and stp_mfh_sequence = (select min(stp_mfh_sequence) from stops where lgh_number = @lgh_number))
	and
	city.cty_code = (select stp_city from stops where lgh_number = @lgh_number and stp_mfh_sequence = (select min(stp_mfh_sequence) from stops where lgh_number = @lgh_number))
	and
	C2.CMP_ID = (select cmp_id from stops where lgh_number = @lgh_number and stp_mfh_sequence = (select max(stp_mfh_sequence) from stops where lgh_number = @lgh_number))
	and
	cty2.cty_code = (select stp_city from stops where lgh_number = @lgh_number and stp_mfh_sequence = (select max(stp_mfh_sequence) from stops where lgh_number = @lgh_number))
end
---
INSERT INTO	@TOrder
SELECT
    legheader.lgh_number,
    Legheader.mov_number,
    legheader.lgh_driver1,
    legheader.lgh_tractor,
    legheader.lgh_carrier,
    orderheader.ord_number,
    orderheader.ord_remark,
    	orderheader.ord_company,
	orderheader.ord_customer,
	orderheader.ord_bookdate,               
	orderheader.ord_bookedby ,       
	orderheader.ord_status ,
	orderheader.ord_originpoint ,
	orderheader.ord_destpoint ,
	orderheader.ord_origincity ,
	orderheader.ord_destcity ,
	orderheader.ord_originstate ,
	orderheader.ord_deststate ,
	orderheader.ord_supplier ,
	orderheader.ord_billto ,
	orderheader.ord_startdate ,
	orderheader.ord_completiondate ,
	isNull((select name from labelfile where labeldefinition = 'revtype1' and abbr = orderheader.ord_revtype1),orderheader.ord_revtype1) ord_revtype1 ,
	isNull((select name from labelfile where labeldefinition = 'revtype2' and abbr = orderheader.ord_revtype2),orderheader.ord_revtype2) ord_revtype2 ,
	isNull((select name from labelfile where labeldefinition = 'revtype3' and abbr = orderheader.ord_revtype3),orderheader.ord_revtype3) ord_revtype3 ,
	isNull((select name from labelfile where labeldefinition = 'revtype4' and abbr = orderheader.ord_revtype4),orderheader.ord_revtype4) ord_revtype4 ,
	orderheader.ord_totalweight ,
	orderheader.ord_totalpieces ,
	orderheader.ord_totalmiles ,
	orderheader.ord_totalcharge ,        
	orderheader.ord_currency ,
	orderheader.ord_currencydate ,
	orderheader.ord_totalvolume,
	orderheader.ord_hdrnumber ,
	orderheader.ord_refnum   ,
	orderheader.ord_invoicewhole ,
	orderheader.ord_shipper ,
	orderheader.ord_consignee,
	orderheader.ord_pu_at,
	orderheader.ord_dr_at ,
	orderheader.ord_contact ,                  
	orderheader.ord_lowtemp ,
	orderheader.ord_hitemp ,
	orderheader.ord_quantity,            
	orderheader.ord_rate     ,             
	orderheader.ord_charge    ,            
	orderheader.ord_rateunit ,
	orderheader.ord_unit ,
	orderheader.trl_type1 ,
	orderheader.ord_driver1,
	orderheader.ord_driver2 ,
	orderheader.ord_tractor ,
	orderheader.ord_trailer ,
	(select [name] from labelfile where labeldefinition = 'TrlType1' and abbr = orderheader.trl_type1) as trl_type1_desc, 
	orderheader.ord_length   ,             
	orderheader.ord_width     ,            
	orderheader.ord_height     ,           
	orderheader.ord_lengthunit ,
	orderheader.ord_widthunit ,
	orderheader.ord_heightunit ,
	orderheader.ord_reftype ,
	orderheader.cmd_code ,
	(select cmd_name from commodity where cmd_code = orderheader.cmd_code) as cmd_name,
	orderheader.ord_description                                                  ,
	orderheader.cht_itemcode ,
	orderheader.ord_origin_earliestdate     ,
	orderheader.ord_origin_latestdate       ,
	orderheader.ord_stopcount ,
	orderheader.ord_dest_earliestdate       ,
	orderheader.ord_dest_latestdate         ,
	orderheader.ord_cmdvalue               ,
	orderheader.ord_accessorial_chrg       ,
	orderheader.ord_availabledate           ,
	orderheader.ord_miscqty                ,
	orderheader.ord_tempunits ,
	orderheader.ord_datetaken  ,            
	orderheader.ord_totalweightunits ,
	orderheader.ord_totalvolumeunits ,
	orderheader.ord_totalcountunits ,
	orderheader.ord_rateby ,
	orderheader.ord_quantity_type ,
	@TotalPieces TotalPieces,
	@TotalWeight TotalWeight,
	@TotalLineHaulPay TotalLineHaulPay,
	@TotalPay TotalPay,
	@StopPay StopPay,
	@PermitPay PermitPay,
	@FuelPay   FuelPay,
	@Pup_stp_comment PupStpComment,
	@Drp_stp_comment DrpStpComment,
	@ModifiedBy ModifiedBy,
	(Select isnull(min(pyd_rate),0)
		FROM
            paydetail inner join paytype on paytype.pyt_itemcode=Paydetail.pyt_itemcode
        WHERE 
            Paydetail.lgh_number = legheader.lgh_number
			and paydetail.asgn_type = 'CAR'
			and paydetail.asgn_id = legheader.lgh_carrier
            and pyt_basis='LGH' ) as carrier_payrate,		
	(select pyd_description 
		from paydetail inner join paytype on paytype.pyt_itemcode=Paydetail.pyt_itemcode
        WHERE Paydetail.lgh_number = legheader.lgh_number
			and paydetail.asgn_type = 'CAR'
			and paydetail.asgn_id = legheader.lgh_carrier
			and pyt_basis='LGH') as pyd_description
FROM
    orderheader,
    company AS C1,
    company AS C2,
    city as cty1,
    city as cty2,
    legheader
WHERE   orderheader.mov_number = @mov_number
    AND    C1.CMP_ID = orderheader.ORD_SHIPPER
    AND    C2.CMP_ID = orderheader.ORD_CONSIGNEE
    and    cty1.cty_code = C1.cmp_city
    and    cty2.cty_code = C2.cmp_city
    AND    legheader.lgh_number= @Lgh_number

INSERT INTO	@TPay
SELECT lgh_number,mov_number,
	lgh_driver1,
    	lgh_tractor,lgh_carrier,ord_number,ord_remark,ord_company,ord_customer,ord_bookdate,ord_bookedby,
ord_status,ord_originpoint,ord_destpoint,ord_origincity,ord_destcity,ord_originstate,ord_deststate,
ord_supplier,ord_billto,ord_startdate,ord_completiondate,ord_revtype1,ord_revtype2,ord_revtype3,
ord_revtype4,ord_totalweight,ord_totalpieces,ord_totalmiles,ord_totalcharge,ord_currency,ord_currencydate,
ord_totalvolume,ord_hdrnumber,ord_refnum,ord_invoicewhole,ord_shipper,ord_consignee,ord_pu_at,ord_dr_at,
ord_contact,ord_lowtemp,ord_hitemp,ord_quantity,ord_rate,ord_charge,ord_rateunit,ord_unit,trl_type1,
ord_driver1,ord_driver2,ord_tractor,ord_trailer,trl_type1_desc,ord_length,ord_width,ord_height,ord_lengthunit,
ord_widthunit,ord_heightunit,ord_reftype,cmd_code,cmd_name,ord_description,cht_itemcode,ord_origin_earliestdate,
ord_origin_latestdate,ord_stopcount,ord_dest_earliestdate,ord_dest_latestdate,ord_cmdvalue,ord_accessorial_chrg,
ord_availabledate,ord_miscqty,ord_tempunits,ord_datetaken,ord_totalweightunits,ord_totalvolumeunits,ord_totalcountunits,
ord_rateby,ord_quantity_type,TotalPieces,TotalWeight,TotalLineHaulPay,TotalPay,StopPay,PermitPay,FuelPay,
PupStpComment,DrpStpComment,ModifiedBy,carrier_payrate,pyd_description,
	( SELECT 
		SUM(pyd_amount)
        	FROM
            	paydetail,
		TOrder
        	WHERE
        	Paydetail.lgh_number= @Lgh_number
	) - (TR.TotalLineHaulPay + TR.fuelPay) 	OtherPay
    FROM @TOrder TR

-- Add Carrier fields
INSERT INTO	@TCarrier
Select	lgh_number,lgh_carrier,ord_number,ord_remark,ord_company,ord_customer,ord_bookdate,ord_bookedby,
ord_status,ord_originpoint,ord_destpoint,ord_origincity,ord_destcity,ord_originstate,ord_deststate,
ord_supplier,ord_billto,ord_startdate,ord_completiondate,ord_revtype1,ord_revtype2,ord_revtype3,
ord_revtype4,ord_totalweight,ord_totalpieces,ord_totalmiles,ord_totalcharge,ord_currency,ord_currencydate,
ord_totalvolume,ord_hdrnumber,ord_refnum,ord_invoicewhole,ord_shipper,ord_consignee,ord_pu_at,ord_dr_at,
ord_contact,ord_lowtemp,ord_hitemp,ord_quantity,ord_rate,ord_charge,ord_rateunit,ord_unit,trl_type1,
ord_driver1,ord_driver2,ord_tractor,ord_trailer,trl_type1_desc,ord_length,ord_width,ord_height,ord_lengthunit,
ord_widthunit,ord_heightunit,ord_reftype,cmd_code,cmd_name,ord_description,cht_itemcode,ord_origin_earliestdate,
ord_origin_latestdate,ord_stopcount,ord_dest_earliestdate,ord_dest_latestdate,ord_cmdvalue,ord_accessorial_chrg,
ord_availabledate,ord_miscqty,ord_tempunits,ord_datetaken,ord_totalweightunits,ord_totalvolumeunits,ord_totalcountunits,
ord_rateby,ord_quantity_type,TotalPieces,TotalWeight,TotalLineHaulPay,TotalPay,StopPay,PermitPay,FuelPay,
PupStpComment,DrpStpComment,ModifiedBy,pyd_description, Otherpay,
	(Select 
			Max(ref_number)
		FROM
			ReferenceNumber
		where
			ref_tablekey= TP.ord_hdrnumber
			AND
			ref_table='orderheader'
			and
			ref_number<>ord_refnum
	) Ord_RefNum2,
	car_name,
	Car_id,
	car_phone1,
	car_phone2,
	car_phone3,
	car_fedid,
	car_scac,
	car_contact,
	car_type1,
	car_type2,
	car_type3,
	car_type4,
	car_misc1,
	car_misc2,
	car_misc3,
	car_misc4,
	car_actg_type,
	car_iccnum,
	car_contract,
	car_otherid,
	car_usecashcard,
	car_status,
	car_board 
	from @TPay TP
	left outer join carrier on lgh_carrier = carrier.car_id

	-- Select all the temp results
if @LegCount = 1
	Select 
tc.lgh_number ,tc.lgh_carrier ,tc.ord_number  ,tc.ord_remark ,tc.ord_company ,tc.ord_customer ,
tc.ord_bookdate , tc.ord_bookedby  ,       tc.ord_status  ,tc.ord_originpoint ,tc.ord_destpoint ,
tc.ord_origincity ,tc.ord_destcity ,tc.ord_originstate  ,tc.ord_deststate ,tc.ord_supplier ,tc.ord_billto ,
tc.ord_startdate ,tc.ord_completiondate ,tc.ord_revtype1 ,tc.ord_revtype2 ,tc.ord_revtype3 ,tc.ord_revtype4 ,
tc.ord_totalweight  ,tc.ord_totalpieces  ,tc.ord_totalmiles  ,tc.ord_totalcharge ,        tc.ord_currency ,tc.ord_currencydate ,
tc.ord_totalvolume ,tc.ord_hdrnumber ,tc.ord_refnum ,tc.ord_invoicewhole ,tc.ord_shipper ,tc.ord_consignee ,tc.ord_pu_at ,
tc.ord_dr_at ,tc.ord_contact ,                  tc.ord_lowtemp ,tc.ord_hitemp ,tc.ord_quantity ,            tc.ord_rate ,             
tc.ord_charge , tc.ord_rateunit ,tc.ord_unit ,tc.trl_type1 ,tc.ord_driver1 ,tc.ord_driver2 ,tc.ord_tractor ,
tc.ord_trailer ,tc.trl_type1_desc , tc.ord_length ,             tc.ord_width ,            tc.ord_height ,           tc.ord_lengthunit ,
tc.ord_widthunit ,tc.ord_heightunit ,tc.ord_reftype ,tc.cmd_code ,tc.cmd_name ,tc.ord_description ,
tc.cht_itemcode ,tc.ord_origin_earliestdate ,tc.ord_origin_latestdate ,tc.ord_stopcount ,tc.ord_dest_earliestdate ,
tc.ord_dest_latestdate ,tc.ord_cmdvalue ,tc.ord_accessorial_chrg ,tc.ord_availabledate ,tc.ord_miscqty ,
tc.ord_tempunits ,tc.ord_datetaken  ,            tc.ord_totalweightunits ,tc.ord_totalvolumeunits ,tc.ord_totalcountunits ,
tc.ord_rateby ,tc.ord_quantity_type ,tc.TotalPieces ,tc.TotalWeight ,tc.TotalLineHaulPay ,
tc.TotalPay ,tc.StopPay ,tc.PermitPay ,tc.FuelPay ,tc.PupStpComment  ,
tc.DrpStpComment  ,tc.ModifiedBy  ,tc.pyd_description ,tc.OtherPay ,
tc.Ord_RefNum2 ,tc.car_name ,tc.Car_id ,tc.car_phone1 ,tc.car_phone2 ,tc.car_phone3 ,
tc.car_fedid ,tc.car_scac ,tc.car_contact ,tc.car_type1 ,tc.car_type2 ,tc.car_type3 ,
tc.car_type4 ,tc.car_misc1 ,tc.car_misc2 ,tc.car_misc3 ,tc.car_misc4 ,tc.car_actg_type ,tc.car_iccnum ,
tc.car_contract ,tc.car_otherid ,tc.car_usecashcard ,tc.car_status ,tc.car_board , 
		tn.ORD_SHIPPER ,
tn.ORD_CONSIGNEE ,
tn.shipper_CMP_NAME ,
tn.shipper_cmp_address1  ,
tn.shipper_cmp_address2  ,
tn.shipper_cty_nmstct ,
tn.shipper_cty_nmstctFULL ,
tn.shipper_cmp_zip  ,
tn.shipper_cmp_primaryphone  ,
tn.Consignee_CMP_NAME ,
tn.Consignee_cmp_address1 ,
tn.Consignee_cmp_address2 ,
tn.Consignee_cty_nmstct ,
tn.Consignee_cty_nmstctFULL ,
tn.Consignee_cmp_zip ,
tn.Consignee_cmp_primaryphone , 
		@BrokerageNotes as BrokerNotes, 
		@LineHaulPayCurrency as LineHaulPayCurrency, 
		@FuelPayCurrency as FuelPayCurrency, 
		@OtherPayCurrency as OtherPayCurrency,
		@contact_name as Contact,
		@contact_phone as Contact_phone,
		@loadreq_exist as LoadReqMandatory,
		@stp_comment as stp_comment,
		@PickupNum as Pickup_Num  
	from @TCarrier tc, @TNormal tn
else
	Select 
tc.lgh_number ,tc.lgh_carrier ,tc.ord_number  ,tc.ord_remark ,tc.ord_company ,tc.ord_customer ,
tc.ord_bookdate , tc.ord_bookedby  ,       tc.ord_status  ,tc.ord_originpoint ,tc.ord_destpoint ,
tc.ord_origincity ,tc.ord_destcity ,tc.ord_originstate  ,tc.ord_deststate ,tc.ord_supplier ,tc.ord_billto ,
tc.ord_startdate ,tc.ord_completiondate ,tc.ord_revtype1 ,tc.ord_revtype2 ,tc.ord_revtype3 ,tc.ord_revtype4 ,
tc.ord_totalweight  ,tc.ord_totalpieces  ,tc.ord_totalmiles  ,tc.ord_totalcharge ,        tc.ord_currency ,tc.ord_currencydate ,
tc.ord_totalvolume ,tc.ord_hdrnumber ,tc.ord_refnum ,tc.ord_invoicewhole ,tc.ord_shipper ,tc.ord_consignee ,tc.ord_pu_at ,
tc.ord_dr_at ,tc.ord_contact ,                  tc.ord_lowtemp ,tc.ord_hitemp ,tc.ord_quantity ,            tc.ord_rate ,             
tc.ord_charge , tc.ord_rateunit ,tc.ord_unit ,tc.trl_type1 ,tc.ord_driver1 ,tc.ord_driver2 ,tc.ord_tractor ,
tc.ord_trailer ,tc.trl_type1_desc , tc.ord_length ,             tc.ord_width ,            tc.ord_height ,           tc.ord_lengthunit ,
tc.ord_widthunit ,tc.ord_heightunit ,tc.ord_reftype ,tc.cmd_code ,tc.cmd_name ,tc.ord_description ,
tc.cht_itemcode ,tc.ord_origin_earliestdate ,tc.ord_origin_latestdate ,tc.ord_stopcount ,tc.ord_dest_earliestdate ,
tc.ord_dest_latestdate ,tc.ord_cmdvalue ,tc.ord_accessorial_chrg ,tc.ord_availabledate ,tc.ord_miscqty ,
tc.ord_tempunits ,tc.ord_datetaken  ,            tc.ord_totalweightunits ,tc.ord_totalvolumeunits ,tc.ord_totalcountunits ,
tc.ord_rateby ,tc.ord_quantity_type ,tc.TotalPieces ,tc.TotalWeight ,tc.TotalLineHaulPay ,
tc.TotalPay ,tc.StopPay ,tc.PermitPay ,tc.FuelPay ,tc.PupStpComment  ,
tc.DrpStpComment  ,tc.ModifiedBy  ,tc.pyd_description ,tc.OtherPay ,
tc.Ord_RefNum2 ,tc.car_name ,tc.Car_id ,tc.car_phone1 ,tc.car_phone2 ,tc.car_phone3 ,
tc.car_fedid ,tc.car_scac ,tc.car_contact ,tc.car_type1 ,tc.car_type2 ,tc.car_type3 ,
tc.car_type4 ,tc.car_misc1 ,tc.car_misc2 ,tc.car_misc3 ,tc.car_misc4 ,tc.car_actg_type ,tc.car_iccnum ,
tc.car_contract ,tc.car_otherid ,tc.car_usecashcard ,tc.car_status ,tc.car_board , 
		ts.shipper_CMP_NAME ,
ts.shipper_cmp_address1 ,
ts.shipper_cmp_address2 ,
ts.shipper_cty_nmstct ,
ts.shipper_cty_nmstctFULL ,
ts.shipper_cmp_zip ,
ts.shipper_cmp_primaryphone ,
ts.Consignee_CMP_NAME ,
ts.Consignee_cmp_address1 ,
ts.Consignee_cmp_address2 ,
ts.Consignee_cty_nmstct ,
ts.Consignee_cty_nmstctFULL ,	
ts.Consignee_cmp_zip ,
ts.Consignee_cmp_primaryphone, 
		@BrokerageNotes as BrokerNotes, 
		@LineHaulPayCurrency as LineHaulPayCurrency, 
		@FuelPayCurrency as FuelPayCurrency, 
		@OtherPayCurrency as OtherPayCurrency,
		@contact_name as Contact,
		@contact_phone as Contact_phone,
		@loadreq_exist as LoadReqMandatory,
		@stp_comment as stp_comment,
		@PickupNum as Pickup_Num   
	from @TCarrier tc, @Tsplit ts

ende:




GO
