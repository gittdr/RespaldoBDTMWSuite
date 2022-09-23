SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[WORD_InterfaceEXAMPLE]
		@lgh_number int
as
/*************************

exec WORD_InterfaceEXAMPLE_23805 24425

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
    select 
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
	into #Tnormal
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
    select 
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
	into #TSplit
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
/*
    C1.CMP_NAME         shipper_CMP_NAME ,
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
    C2.cmp_primaryphone     Consignee_cmp_primaryphone,
*/
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
Into #TOrder
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


SELECT #TOrder.*,
	( SELECT 
		SUM(pyd_amount)
        	FROM
            	paydetail,
		#TOrder
        	WHERE
        	Paydetail.lgh_number= @Lgh_number
	) - (#TOrder.TotalLineHaulPay + #TOrder.fuelPay) 
	OtherPay
    into #TPay
    FROM #TOrder

-- Add Carrier fields
Select	#TPay.*, 
	(Select 
			Max(ref_number)
		FROM
			ReferenceNumber
		where
			ref_tablekey= #TPay.ord_hdrnumber
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

	into #TCarrier
-- 	from
-- 		carrier,
-- 		#TPay
--         where 		
-- 	    	lgh_carrier*=carrier.car_id
	from #TPay
	left outer join carrier on lgh_carrier = carrier.car_id

	-- Select all the temp results
if @LegCount = 1
	Select #TCarrier.*, 
		#TNormal.*, 
		@BrokerageNotes as BrokerNotes, 
		@LineHaulPayCurrency as LineHaulPayCurrency, 
		@FuelPayCurrency as FuelPayCurrency, 
		@OtherPayCurrency as OtherPayCurrency,
		@contact_name as Contact,
		@contact_phone as Contact_phone,
		@loadreq_exist as LoadReqMandatory,
		@stp_comment as stp_comment,
		@PickupNum as Pickup_Num  
	from #TCarrier, #TNormal
else
	Select #TCarrier.*, 
		#TSplit.*, 
		@BrokerageNotes as BrokerNotes, 
		@LineHaulPayCurrency as LineHaulPayCurrency, 
		@FuelPayCurrency as FuelPayCurrency, 
		@OtherPayCurrency as OtherPayCurrency,
		@contact_name as Contact,
		@contact_phone as Contact_phone,
		@loadreq_exist as LoadReqMandatory,
		@stp_comment as stp_comment,
		@PickupNum as Pickup_Num   
	from #TCarrier, #TSplit

ende:
GO
GRANT EXECUTE ON  [dbo].[WORD_InterfaceEXAMPLE] TO [public]
GO
