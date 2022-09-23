SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[d_masterbill135_sp] (	@reprintflag varchar(10), @mbnumber int, @billto varchar(8),   
															@revtype1 varchar(6), @revtype2 varchar(6),@revtype3 varchar(6), 
															@revtype4 varchar(6),@mbstatus varchar(6), @shipstart datetime,
															@shipend datetime,@billdate datetime, @shipper varchar(8), 
															@consignee varchar(8), @delstart datetime, @delend datetime,	
															@orderby varchar(8),@copy tinyint, @ivhcompany varchar(6),
															@Currency varchar(6),@carkey int  )  
AS
/**		REVISION HISTORY:
		PTS45203 AUTOPAY MB JSwindell 2-11-2009 NEW MB 134 CREATED (using mb134 as template)
		PTS47380 JSwindell 5-7-2009  1) Client wants Consignee name instead of city/state when break on SHIPPER only.
									 2) show $$ amount when MIN charge (instead of "autopay")
		PTS47380 JSwindell 5-18-09:  Addtl New Requirements: 2 trailers and PO#.
		PTS48063 JSwindell 6/30/09:  For AutoPay we DON'T want the inv to produce output If there are no accessorial or line item charges.
		PTS48073 JSwindell 6/30/09:  Allow ANY reference number, also need ref type where 47380 was showing only PO#.
		PTS48073 JSwindell 7/08/09:  added code to recognize "MIN" line items.  Look for comments =   --PTS48073-7-8-09 
		PTS48073 JSwindell 7/09/09:  Change IVD_QUANTITY to dec(19,4)   --PTS48073-7-8-09 
 **/


DECLARE @SIDType varchar(6), @FBCRefType varchar(6),@NoPrintEvent varchar(100)  
  
Select @NoPrintEvent = ','+gi_string1+',' From generalinfo where gi_name = 'InvoiceNoPrintEvent'  
Select @NoPrintEvent = IsNull(@NoPrintEvent,',,') 
Select @Currency = IsNull(@currency,'Z-C$')
If @Currency = 'UNK' Select @Currency = 'Z-C$' 

--------  PTS 45203 Client Wants the Currency to be the BILLTO Currency from company profile.
Set @Currency = (select cmp_currency from company where cmp_id = @billto )

Declare @GSTNUMBER varchar(30)
if exists (select 1 from generalinfo where gi_name = 'GSTNUMBER' ) 
	BEGIN
		SET @GSTNUMBER = (select gi_string1  from generalinfo where gi_name = 'GSTNUMBER')
	END
  
	-- per DSK should use gi setting DefaultStopRefFromCOmpID for SID ref type and assume a number will be appended at end  
	-- to handle how that value will override the one on the stop (value probably SID1  
	Select @SIDType = Case Datalength(RTRIM(IsNull(gi_string1,'')))  
		WHen 0 Then ''  
		When 1 Then RTRIM(gi_string1)  
		Else Substring(RTRIM(gi_string1),1,datalength(RTRIM(gi_string1)) - 1 )  
		End  
	From generalinfo Where gi_name = 'DefaultStopRefFromCompID'  
	Select @SIDType = IsNull(@SIDType,'')  
	  
	Select @FBCRefType = RTRIM(gi_string1)  
	From generalinfo Where gi_name = 'RefType-Manifest'  
	Select @FBCRefType = IsNull(@FBCRefType,'')  

create table #TEMP_MB (	
		ivh_invoicenumber  	    varchar (12)  NULL,   
		ivh_hdrnumber  			INT  NULL,     
		ivh_billto  			varchar (8)  NULL,   
		ivh_totalcharge  	    decimal  (19,4)  NULL,   
		ivh_originpoint  	    varchar (8)  NULL,   
		ivh_destpoint  			varchar (8)  NULL,   
		ivh_origincity  	    INT  NULL,    
		ivh_destcity  			INT  NULL,     
		ivh_shipdate  			datetime  NULL,
		ivh_deliverydate  	    datetime  NULL,
		ivh_revtype1  			varchar (6)  NULL,   
		ivh_mbnumber  			INT NULL,     
		billto_name  			varchar (100)  NULL,   
		billto_address  	    varchar (100)  NULL,   
		billto_address2  	    varchar (100)  NULL,   
		billto_nmstct  			varchar (30)  NULL,   
		billto_zip  			varchar (10)  NULL,   
		origin_nmstct  			varchar (25)  NULL,   
		origin_state  			varchar (6)  NULL,   
		dest_nmstct  			varchar (25)  NULL,   
		dest_state  			varchar (6)  NULL,   
		billdate  				Datetime   NULL,   
		SID_refnumber  			varchar (20)  NULL,   
		cmp_mailto_name  	    varchar (30)  NULL,   
		ord_number  			varchar (17)  NULL,   
		manifest_number  	    varchar (20)  NULL,   
		ivd_description  	    varchar (60)  NULL,   
		charge_item  			varchar (30)  NULL,   
		--ivd_quantity  			INT  NULL,	--PTS48073-7-8-09  change to dec(19...)
		ivd_quantity  			decimal  (19,4)  NULL, 
		ivd_rate  				decimal  (19,4)  NULL,   
		ivd_charge  			decimal  (19,4)  NULL,   
		cht_basis  				varchar (6)  NULL,   
		cht_taxtable1  			varchar (1)  NULL,   
		cht_taxtable2  			varchar (1)  NULL,   
		cht_taxtable3  			varchar (1)  NULL,   
		cht_taxtable4  			varchar (1)  NULL,   
		ivd_type  				varchar (6)  NULL,   
		cht_rollintolh  	    INT NULL,   
		copy  					INT  NULL,   
		cht_primary  			varchar (1)  NULL,   
		fbc_manifest  			varchar (1)  NULL,   
		ivd_sequence  			INT  NULL,    
		ivh_revtype2  			varchar (6)  NULL,   
		ivh_remark  			varchar (254)  NULL,   
		ShipperID  				varchar (8)  NULL,   
		shipper_name  			varchar (100)  NULL,   
		shipper_citystate  	    varchar (25)  NULL,   
		cht_itemcode  			varchar (6)  NULL,   
		cht_description  	    varchar (30)  NULL,   
		ord_hdrnumber  			INT  NULL,    
		Currency  				varchar (6)  NULL,   
		ivd_wgt  				INT NULL,   
		ivd_volume  			INT  NULL,   
		ivd_wgtunit  			varchar (6)  NULL,   
		ivd_volunit  			varchar (6)  NULL,   
		billunit  				varchar (20)  NULL,   
		GSTNUMBER  				varchar (30)  NULL,   
		not_text  				varchar (254)  NULL,   
		BOL_stop_ref  			varchar (30)  NULL,   
		ivh_quantity  			int  NULL,  
		cmp_mbgroup  			varchar (20)  NULL,   
		CONSIGNEE_ID  			varchar (8)  NULL,   
		CONSIGNEE_name  	    varchar (100)  NULL,   
		CONSIGNEE_citystate  	varchar (25)  NULL,   
		FUEL_SURCHARGE  	    decimal  (19,4)  NULL,
		NEW_TAX_AMOUNT			decimal  (19,4)  NULL, 
		--------------------------------------
		ls_freightdetail_bol varchar(300) null,  
		not_text1 varchar(254) null,			  
		not_text2 varchar(254) null,			  
		not_text3 varchar(254) null,			 
		not_text4 varchar(254) null,			 
		not_text5 varchar(254) null,  
		save_ivd_charge  			decimal  (19,4)  NULL,  -- total line=hauled volume goes away when ivd_charge zeroed out.
		ivh_consignee varchar(8) null,			  -- PTS 47380
		ivh_CONSIGNEE_name varchar (100)  NULL,   -- PTS 47380 
		--------------------------------------
		ivh_trailer		varchar (13)  NULL,			-- PTS 47380 5/18 New Req
		evt_trailer2	varchar (13)  NULL,			-- PTS 47380 5/18 New Req
		PO_Nbr_ref  	varchar (30)  NULL,			-- PTS 47380 5/18 New Req
		--------------------------------------
		ll_nooutput		int NULL,					-- PTS 48063 6/30/09 
		Cust_REF_Nbr	varchar (300)  NULL,		-- PTS 48073 6/30/09 
		--------------------------------------
		CC_IDENTITY				INT IDENTITY 
)
  
If UPPER(@reprintflag) = 'REPRINT'   
  BEGIN  
  
INSERT INTO #TEMP_MB (	ivh_invoicenumber , 
						ivh_hdrnumber , 
						ivh_billto , 
						ivh_totalcharge,  
						ivh_originpoint , 
						ivh_destpoint , 
						ivh_origincity,  
						ivh_destcity, 
						ivh_shipdate,  
						ivh_deliverydate,  
						ivh_revtype1,  
						ivh_mbnumber,  
						billto_name,  
						billto_address,  
						billto_address2,  
						billto_nmstct,  
						billto_zip,  
						origin_nmstct,  
						origin_state,  
						dest_nmstct,  
						dest_state,  
						billdate,  
						SID_refnumber,  
						cmp_mailto_name,  
						ord_number,  
						manifest_number,  
						ivd_description,  
						charge_item,  
						ivd_quantity,  
						ivd_rate,  
						ivd_charge,  
						cht_basis,  
						cht_taxtable1,  
						cht_taxtable2,  
						cht_taxtable3 , 
						cht_taxtable4, 
						ivd_type,  
						cht_rollintolh,  
						copy,  
						cht_primary,  
						fbc_manifest,  
						ivd_sequence,  
						ivh_revtype2,  
						ivh_remark,  
						ShipperID,  
						shipper_name,  
						shipper_citystate,  
						cht_itemcode,  
						cht_description,  
						ord_hdrnumber,  
						Currency,  
						ivd_wgt,  
						ivd_volume,  
						ivd_wgtunit,  
						ivd_volunit,  
						billunit,  
						GSTNUMBER , 
						not_text,  
						BOL_stop_ref,  
						ivh_quantity,  
						cmp_mbgroup,  
						CONSIGNEE_ID,  
						CONSIGNEE_name,  
						CONSIGNEE_citystate,  
						FUEL_SURCHARGE,  
						NEW_TAX_AMOUNT,
						ls_freightdetail_bol,   
						not_text1, 		  
						not_text2,			  
						not_text3, 		 
						not_text4, 		 
						not_text5,
						save_ivd_charge,
						ivh_consignee,		-- PTS 47380
						ivh_CONSIGNEE_name	-- PTS 47380
						,ivh_trailer		-- PTS 47380 5/18 New Req
						,evt_trailer2		-- PTS 47380 5/18 New Req
						,PO_Nbr_ref			-- PTS 47380 5/18 New Req
						,ll_nooutput		-- PTS 48063 6/30/09 
						,Cust_REF_Nbr		-- PTS 48073 6/30/09 
)

  Select  DISTINCT
  ivh_invoicenumber  
  ,IH.ivh_hdrnumber  
  ,ivh_billto  
  ,ivh_totalcharge  
  ,ivh_showshipper   --ivh_originpoint  
  ,ivh_showcons      --ivh_destpoint  
  ,ivh_origincity = ocmp.cmp_city  
  ,ivh_destcity = dcmp.cmp_city 
  ,ivh_shipdate  
  ,ivh_deliverydate  
  ,ivh_revtype1  
  ,ivh_mbnumber  
  ,billto_name = 
    CASE isnull(IH.car_key,0)
      WHEN 0 THEN ISNULL(BCMP.cmp_name,'')
      ELSE isnull(car_name,'')
      END  
  ,billto_address =
   CASE isnull(IH.car_key,0)
     WHEN 0 then   
        CASE Rtrim(IsNull(BCMP.cmp_mailto_name,''))  
        WHEN '' THEN ISNULL(BCMP.cmp_address1,'')  
        ELSE ISNULL(BCMP.cmp_mailto_address1,'')  
        END  
     ELSE 
        Isnull(car_address1,'')
     END
  ,billto_address2 =
   CASE isnull(IH.car_key,0)
     WHEN 0 then     
        CASE Rtrim(IsNull(BCMP.cmp_mailto_name,''))  
           WHEN '' THEN ISNULL(BCMP.cmp_address2,'')  
           ELSE ISNULL(BCMP.cmp_mailto_address2,'')  
           END
     ELSE IsNull(car_address2,'')
     END  
  ,billto_nmstct = 
    CASE IsNull(IH.car_key,0)
      WHEN 0 THEN  
         CASE Rtrim(IsNull(BCMP.cmp_mailto_name,''))  
         WHEN '' THEN   
            ISNULL(SUBSTRING(BCMP.cty_nmstct,1,(CHARINDEX('/',BCMP.cty_nmstct))- 1),'')  
         ELSE ISNULL(SUBSTRING(BCMP.mailto_cty_nmstct,1,(CHARINDEX('/',BCMP.mailto_cty_nmstct)) - 1),'')  
         END 
     ELSE Isnull(car_nmstct,'') 
     END 
  ,billto_zip =  
     CASE Isnull(IH.car_key,0)
       WHEN 0 THEN 
          CASE Rtrim(IsNull(BCMP.cmp_mailto_name,''))  
          WHEN ''  THEN ISNULL(BCMP.cmp_zip ,'')    
          ELSE ISNULL(BCMP.cmp_mailto_zip,'')  
          END 
       ELSE isnull( car_zip,'')
       END
  ,origin_city =   
   Case Charindex(',',OCMP.cty_nmstct)  
     When 0 Then ''  
     Else SubString(OCMP.cty_nmstct,1,charindex(',',OCMP.cty_nmstct) - 1)  
     End  
  ,origin_state = Case IsNull(OCMP.cmp_state,'XX') When 'XX' Then '' Else OCMP.cmp_state End  
  ,dest_city = 
    Case IDT.cmp_id
      When  IH.ivh_consignee Then -- this is the consignee DRP, use the showcons info
           Case Charindex(',',DCMP.cty_nmstct)  
           When 0 Then ''  
          Else SubString(DCMP.cty_nmstct,1,charindex(',',DCMP.cty_nmstct) - 1)  
          End 
      ELSE  Case Charindex(',',DDCMP.cty_nmstct)   -- not consignee PUP use IDT.cmp_id info 
           When 0 Then ''  
          Else SubString(DDCMP.cty_nmstct,1,charindex(',',DDCMP.cty_nmstct) - 1)  
          End
      END 
  ,dest_state = 
     Case IDT.cmp_id
        When IH.ivh_consignee Then -- this is the consignee drop use showcons info
             Case IsNull(DCMP.cmp_state,'XX') When 'XX' Then '' Else DCMP.cmp_state End
        Else Case IsNull(DDCMP.cmp_state,'XX') When 'XX' Then '' Else DDCMP.cmp_state End
        ENd  
  ,ivh_billdate  
  ,SID_refnumber = Case IsNull(IDT.stp_number ,0) When 0 then '' Else 
      (select ref_number from referencenumber where ref_table = 'stops'
       and ref_tablekey = IDT.stp_number 
       and ref_type = @SIDType
       and ref_sequence = (select min(ref_sequence) from referencenumber
                           where ref_table = 'stops' and ref_tablekey = IDT.stp_number
                           and ref_type = @SIDType)) end   --IsNull(SREF.ref_number,'')       
  ,mailto_name = Rtrim(ISNULL(BCMP.cmp_mailto_name,''))  
  ,ord_number = Case IH.ord_number WHen '0' Then 'Misc '+ivh_invoicenumber Else IH.Ord_number End  
 -- ,manifest_number = IsNull(MREF.ref_number,'')  
  ,manifest_number = Case IsNull(ivd_reftype,'UNK') When @FBCRefType Then IsNull(ivd_refnum,'') else '' End  
  ,ivd_description = Case IsNull(ivd_description,'UNKNOWN') 
     When 'UNKNOWN' Then IsNull(CHT.cht_description,'') 
     Else Case IDT.cht_itemcode When 'MIN' Then cht_description Else ivd_description End 
     End
  ,charge_item = Case IDT.cht_itemcode When 'MIN' then cht_description  Else IsNull(CTL.name,'')End  
  ,ivd_quantity = IsNull(ivd_quantity,0)  
  ,ivd_rate = IsNull(ivd_rate,0)  

 -- ,ivd_charge = IsNull(ivd_charge,0)  --- AUTOPAY modification
 -- ,ivd_charge = CASE cht_primary WHEN 'Y' THEN 0 else CASE IDT.cht_rollintoLH WHEN 1 THEN 0 ELSE IsNull(ivd_charge,0)  END END --pts47380
		,ivd_charge = CASE cht_primary 
				  WHEN 'Y' THEN CASE IDT.cht_itemcode
							    WHEN 'MIN' THEN IsNull(ivd_charge,0)
								else 0  end
				  else CASE IDT.cht_rollintoLH WHEN 1 THEN 0 ELSE IsNull(ivd_charge,0)  END END
 
 ,cht_basis = IsNull(cht_basis,'UNK')  
  ,cht_taxtable1 = IsNull(cht_taxtable1,'N')  
  ,cht_taxtable2 = IsNull(cht_taxtable2,'N')  
  ,cht_taxtable3 = IsNull(cht_taxtable3,'N')  
  ,cht_taxtable4 = IsNull(cht_taxtable4,'N')  
  ,ivd_type = IsNull(ivd_type,'UNK')  
  ,cht_rollintoLH = IsNull(IDT.cht_rollintoLH ,0)  
  ,copy = @copy  
  ,cht_primary = IsNull(cht_primary,'N')  
 -- ,fbc_manifest = IsNull((Select MAX(IsNull(fbc_refnumber,'')) From freight_by_compartment FBC Where FBC.fgt_number = IDT.fgt_number),'')  
  ,fbc_manifest = 'X'  
  ,ivd_sequence 
  ,ivh_revtype2 
  , ' ' as 'ivh_remark'  --- PTS 45203 :remove the remark - replace w/ notes
  --,ivh_remark = IsNull(Replace(Replace(ivh_remark,Char(13),' '),char(10),''),'')
--  ,ShipperID = Case IsNull(ivh_shipper,'UNKNOWN') When 'UNKNOWN' Then 'N/A' Else ivh_shipper End
  ,ShipperID = Case IsNull(ivh_showshipper,'UNKNOWN') When 'UNKNOWN' Then 'N/A' Else ivh_showshipper End
  ,Shipper_name = IsNull(OCMP.cmp_name,'')
  ,Shipper_citystate = IsNull(Case Charindex('/',OCMP.cty_nmstct) 
      When 0 Then OCMP.cty_nmstct 
      Else   Left(OCMP.cty_nmstct,Charindex('/',OCMP.cty_nmstct) - 1) End,'')
  ,IDT.cht_itemcode
  ,CHT.cht_description
  ,ih.ord_hdrnumber
  ,@Currency as 'Currency'
  ,ivd_wgt = Case isnull(IDT.ivd_type,'') When 'DRP' then ivd_wgt else 0 end
  ,ivd_volume = case isnull(IDT.ivd_type,'') WHen 'DRP' then ivd_volume else 0 end
  ,ivd_wgtunit = Case isnull(IDT.ivd_type,'') When 'DRP' then ivd_wgtunit else '' end
  ,ivd_volunit = Case isnull(IDT.ivd_type,'') When 'DRP' then ivd_volunit else '' end
  ,billunit = case CHT.cht_primary WHen 'Y' Then LBL.name else '' end
  ,@GSTNUMBER	as 'GSTNUMBER'		--PTS 45203
---------------------
,' ' as 'not_text'
,' ' as 'BOL_stop_ref'
  ----,(select min(not_text) from notes where  not_type = 'B' and  nre_tablekey = cast(ih.ord_hdrnumber as varchar(18)) and  not_sequence = (select min(not_sequence) from notes where  not_type = 'B' and  nre_tablekey = cast(ih.ord_hdrnumber as varchar(18)))) 'not_text'
  ----,(select min(REF_NUMBER) from referencenumber where referencenumber.ord_hdrnumber = ih.ord_hdrnumber and REF_TABLE = 'freightdetail' AND REF_TYPE = 'BL#' and REF_SEQUENCE = (SELECT MIN(REF_SEQUENCE) FROM referencenumber  WHERE referencenumber.ord_hdrnumber = ih.ord_hdrnumber)) as 'BOL_stop_ref'
----------------------  
,ivh_quantity
  ,ISNULL(BCMP.cmp_mbgroup, '') as 'cmp_mbgroup'
  ,CONSIGNEE_ID = Case IsNull(ivh_showcons,'UNKNOWN') When 'UNKNOWN' Then 'N/A' Else ivh_showcons  End
  ,CONSIGNEE_name = IsNull(CCMP.cmp_name,'')
  ,CONSIGNEE_citystate = IsNull(Case Charindex('/',CCMP.cty_nmstct) 
      When 0 Then CCMP.cty_nmstct 
      Else   Left(CCMP.cty_nmstct,Charindex('/',CCMP.cty_nmstct) - 1) End,'')
  ,FUEL_SURCHARGE = CASE IDT.cht_itemcode  WHEN 'FSCP'  then ivd_charge 
									     WHEN 'FSCM'  then ivd_charge 
										 WHEN 'FSCF'  then ivd_charge
										 WHEN 'FSCCAN'  then ivd_charge  
										 ELSE 0 END 
  ,NEW_TAX_AMOUNT = IVD_CHARGE 
,ls_freightdetail_bol = ' '
,not_text1 = ' '
,not_text2 = ' '
,not_text3 = ' '
,not_text4 = ' '
,not_text5 = ' '
,ivd_charge = IsNull(ivd_charge,0)
,ivh_consignee		-- PTS 47380
,' ' as ivh_CONSIGNEE_name -- PTS 47380	
-- PTS 47380 5/18 New Req <<start>>
,ivh_trailer	
,evt_trailer2 = (select min(evt_trailer2) from event where event.ord_hdrnumber = IH.ord_hdrnumber and IH.ord_hdrnumber > 0)
,(select min(REF_NUMBER) from referencenumber where referencenumber.ord_hdrnumber = ih.ord_hdrnumber and REF_TABLE = 'orderheader' AND REF_TYPE = 'PO#' and REF_SEQUENCE = (SELECT MIN(REF_SEQUENCE) FROM referencenumber  WHERE referencenumber.ord_hdrnumber = ih.ord_hdrnumber)) as 'PO_Nbr_ref'
-- PTS 47380 5/18 New Req <<end>>
,0 as ll_nooutput		-- PTS 48063 6/30/09 
,Cust_REF_Nbr = ' ' 	-- PTS 48073 6/30/09 

  From invoiceheader IH  
   LEFT OUTER JOIN company BCMP on BCMP.cmp_id = IH.ivh_billto  
   LEFT OUTER JOIN company OCMP on OCMP.cmp_id = ivh_showshipper --ivh_shipper 
   LEFT OUTER JOIN company CCMP on CCMP.cmp_id = ivh_showcons --ivh CONSIGNEE
   LEFT OUTER JOIN companyaddress CAR on CAR.car_key = IH.car_key 
   LEFT OUTER JOIN company DCMP on DCMP.cmp_id = ivh_showcons  -- get dest name and address for show cons
  ,invoicedetail IDT 
   Left  outer join (select labeldefinition,name,abbr From labelfile where labeldefinition in ('WeightUnits','VolumeUnits','CountUnits','TimeUnits')) LBL 
            on LBL.abbr = IDT.ivd_unit    
   LEFT OUTER JOIN company DDCMP on DDCMP.cmp_id = idt.cmp_id   -- get dest info for additional DRPS  
   LEFT OUTER JOIN commodity CMD ON  CMD.cmd_code = IDT.cmd_code  
   Left OUTER JOIN (Select name,abbr From labelfile where labeldefinition = 'RateBy') CTL on CTL.abbr = IsNull(IDT.ivd_rateunit,'')  
   Left OUTER JOIN chargetype CHT on CHT.cht_itemcode = IDT.cht_itemcode  
   Left OUTER JOIN stops on stops.stp_number = IDT.stp_number  
  Where  IH.ivh_Mbnumber =   @mbnumber  
  AND IDT.ivh_hdrnumber = IH.ivh_hdrnumber  
  And Charindex(IsNull(stp_event,'(('),@NoPrintEvent) = 0 
  And IDT.ivd_charge <> 0 
  Order by ShipperID,IH.ivh_invoicenumber,ivd_sequence  
  
  END  

Else  

INSERT INTO #TEMP_MB (	ivh_invoicenumber , 
						ivh_hdrnumber , 
						ivh_billto , 
						ivh_totalcharge,  
						ivh_originpoint , 
						ivh_destpoint , 
						ivh_origincity,  
						ivh_destcity, 
						ivh_shipdate,  
						ivh_deliverydate,  
						ivh_revtype1,  
						ivh_mbnumber,  
						billto_name,  
						billto_address,  
						billto_address2,  
						billto_nmstct,  
						billto_zip,  
						origin_nmstct,  
						origin_state,  
						dest_nmstct,  
						dest_state,  
						billdate,  
						SID_refnumber,  
						cmp_mailto_name,  
						ord_number,  
						manifest_number,  
						ivd_description,  
						charge_item,  
						ivd_quantity,  
						ivd_rate,  
						ivd_charge,  
						cht_basis,  
						cht_taxtable1,  
						cht_taxtable2,  
						cht_taxtable3 , 
						cht_taxtable4, 
						ivd_type,  
						cht_rollintolh,  
						copy,  
						cht_primary,  
						fbc_manifest,  
						ivd_sequence,  
						ivh_revtype2,  
						ivh_remark,  
						ShipperID,  
						shipper_name,  
						shipper_citystate,  
						cht_itemcode,  
						cht_description,  
						ord_hdrnumber,  
						Currency,  
						ivd_wgt,  
						ivd_volume,  
						ivd_wgtunit,  
						ivd_volunit,  
						billunit,  
						GSTNUMBER , 
						not_text,  
						BOL_stop_ref,  
						ivh_quantity,  
						cmp_mbgroup,  
						CONSIGNEE_ID,  
						CONSIGNEE_name,  
						CONSIGNEE_citystate,  
						FUEL_SURCHARGE,  
						NEW_TAX_AMOUNT,
						ls_freightdetail_bol,   
						not_text1, 		  
						not_text2,			  
						not_text3, 		 
						not_text4, 		 
						not_text5,
						save_ivd_charge
						,ivh_consignee			-- PTS 47380
						,ivh_CONSIGNEE_name		-- PTS 47380	
						,ivh_trailer		-- PTS 47380 5/18 New Req
						,evt_trailer2		-- PTS 47380 5/18 New Req
						,PO_Nbr_ref			-- PTS 47380 5/18 New Req	
						,ll_nooutput		-- PTS 48063 6/30/09 
						,Cust_REF_Nbr		-- PTS 48073 6/30/09 
)

  Select  DISTINCT
  ivh_invoicenumber  
  ,IH.ivh_hdrnumber  
  ,ivh_billto  
  ,ivh_totalcharge  
  ,ivh_showshipper   --ivh_originpoint  
  ,ivh_showcons      --ivh_destpoint  
  ,ivh_origincity = ocmp.cmp_city  
  ,ivh_destcity = dcmp.cmp_city 
  ,ivh_shipdate  
  ,ivh_deliverydate  
  ,ivh_revtype1  
  ,@mbnumber ivh_mbnumber  
  ,billto_name = 
    CASE isnull(IH.car_key,0)
      WHEN 0 THEN ISNULL(BCMP.cmp_name,'')
      ELSE isnull(car_name,'')
      END  
  ,billto_address =
   CASE isnull(IH.car_key,0)
     WHEN 0 then   
        CASE Rtrim(IsNull(BCMP.cmp_mailto_name,''))  
        WHEN '' THEN ISNULL(BCMP.cmp_address1,'')  
        ELSE ISNULL(BCMP.cmp_mailto_address1,'')  
        END  
     ELSE 
        Isnull(car_address1,'')
     END
  ,billto_address2 =
   CASE isnull(IH.car_key,0)
     WHEN 0 then     
        CASE Rtrim(IsNull(BCMP.cmp_mailto_name,''))  
           WHEN '' THEN ISNULL(BCMP.cmp_address2,'')  
           ELSE ISNULL(BCMP.cmp_mailto_address2,'')  
           END
     ELSE IsNull(car_address2,'')
     END  
  ,billto_nmstct = 
    CASE IsNull(IH.car_key,0)
      WHEN 0 THEN  
         CASE Rtrim(IsNull(BCMP.cmp_mailto_name,''))  
         WHEN '' THEN   
            ISNULL(SUBSTRING(BCMP.cty_nmstct,1,(CHARINDEX('/',BCMP.cty_nmstct))- 1),'')  
         ELSE ISNULL(SUBSTRING(BCMP.mailto_cty_nmstct,1,(CHARINDEX('/',BCMP.mailto_cty_nmstct)) - 1),'')  
         END 
     ELSE Isnull(car_nmstct,'') 
     END 
  ,billto_zip =  
     CASE Isnull(IH.car_key,0)
       WHEN 0 THEN 
          CASE Rtrim(IsNull(BCMP.cmp_mailto_name,''))  
          WHEN ''  THEN ISNULL(BCMP.cmp_zip ,'')    
          ELSE ISNULL(BCMP.cmp_mailto_zip,'')  
          END 
       ELSE isnull( car_zip,'')
       END
  ,origin_city =   
   Case Charindex(',',OCMP.cty_nmstct)  
     When 0 Then ''  
     Else SubString(OCMP.cty_nmstct,1,charindex(',',OCMP.cty_nmstct) - 1)  
     End  
  ,origin_state = Case IsNull(OCMP.cmp_state,'XX') When 'XX' Then '' Else OCMP.cmp_state End  
  ,dest_city = 
    Case IDT.cmp_id
      When  IH.ivh_consignee Then -- this is the consignee DRP, use the showcons info
           Case Charindex(',',DCMP.cty_nmstct)  
           When 0 Then ''  
          Else SubString(DCMP.cty_nmstct,1,charindex(',',DCMP.cty_nmstct) - 1)  
          End 
      ELSE  Case Charindex(',',DDCMP.cty_nmstct)   -- not consignee PUP use IDT.cmp_id info 
           When 0 Then ''  
          Else SubString(DDCMP.cty_nmstct,1,charindex(',',DDCMP.cty_nmstct) - 1)  
          End
      END 
  ,dest_state = 
     Case IDT.cmp_id
        When IH.ivh_consignee Then -- this is the consignee drop use showcons info
             Case IsNull(DCMP.cmp_state,'XX') When 'XX' Then '' Else DCMP.cmp_state End
        Else Case IsNull(DDCMP.cmp_state,'XX') When 'XX' Then '' Else DDCMP.cmp_state End
        ENd  
  ,@billdate AS 'IVH_BILLDATE' --ivh_billdate  
  ,SID_refnumber = Case IsNull(IDT.stp_number ,0) When 0 then '' Else 
      (select ref_number from referencenumber where ref_table = 'stops'
       and ref_tablekey = IDT.stp_number 
       and ref_type = @SIDType
       and ref_sequence = (select min(ref_sequence) from referencenumber
                           where ref_table = 'stops' and ref_tablekey = IDT.stp_number
                           and ref_type = @SIDType)) end   --IsNull(SREF.ref_number,'')       
  ,mailto_name = Rtrim(ISNULL(BCMP.cmp_mailto_name,''))  
  ,ord_number = Case IH.ord_number WHen '0' Then 'Misc '+ivh_invoicenumber Else IH.Ord_number End  
 -- ,manifest_number = IsNull(MREF.ref_number,'')  
  ,manifest_number = Case IsNull(ivd_reftype,'UNK') When @FBCRefType Then IsNull(ivd_refnum,'') else '' End  
  ,ivd_description = Case IsNull(ivd_description,'UNKNOWN') 
     When 'UNKNOWN' Then IsNull(CHT.cht_description,'') 
     Else Case IDT.cht_itemcode When 'MIN' Then cht_description Else ivd_description End 
     End
  ,charge_item = Case IDT.cht_itemcode When 'MIN' then cht_description  Else IsNull(CTL.name,'')End  
  ,ivd_quantity = IsNull(ivd_quantity,0)  
  ,ivd_rate = IsNull(ivd_rate,0)  

  --------,ivd_charge = IsNull(ivd_charge,0)   -- autopay modification
	--,ivd_charge = CASE cht_primary WHEN 'Y' THEN 0 else CASE IDT.cht_rollintoLH WHEN 1 THEN 0 ELSE IsNull(ivd_charge,0)  END END  --pts47380
		,ivd_charge = CASE cht_primary 
				  WHEN 'Y' THEN CASE IDT.cht_itemcode
							    WHEN 'MIN' THEN IsNull(ivd_charge,0)
								else 0  end
				  else CASE IDT.cht_rollintoLH WHEN 1 THEN 0 ELSE IsNull(ivd_charge,0)  END END

 ,cht_basis = IsNull(cht_basis,'UNK')  
  ,cht_taxtable1 = IsNull(cht_taxtable1,'N')  
  ,cht_taxtable2 = IsNull(cht_taxtable2,'N')  
  ,cht_taxtable3 = IsNull(cht_taxtable3,'N')  
  ,cht_taxtable4 = IsNull(cht_taxtable4,'N')  
  ,ivd_type = IsNull(ivd_type,'UNK')  
  ,cht_rollintoLH = IsNull(IDT.cht_rollintoLH ,0)  
  ,copy = @copy  
  ,cht_primary = IsNull(cht_primary,'N')  
 -- ,fbc_manifest = IsNull((Select MAX(IsNull(fbc_refnumber,'')) From freight_by_compartment FBC Where FBC.fgt_number = IDT.fgt_number),'')  
  ,fbc_manifest = 'X'  
  ,ivd_sequence 
  ,ivh_revtype2 
	, ' ' as 'ivh_remark'  --- PTS 45203 :remove the remark - replace w/ notes
  --,ivh_remark = IsNull(Replace(Replace(ivh_remark,Char(13),' '),char(10),''),'')
--  ,ShipperID = Case IsNull(ivh_shipper,'UNKNOWN') When 'UNKNOWN' Then 'N/A' Else ivh_shipper End
  ,ShipperID = Case IsNull(ivh_showshipper,'UNKNOWN') When 'UNKNOWN' Then 'N/A' Else ivh_showshipper End
  ,Shipper_name = IsNull(OCMP.cmp_name,'')
  ,Shipper_citystate = IsNull(Case Charindex('/',OCMP.cty_nmstct) 
      When 0 Then OCMP.cty_nmstct 
      Else   Left(OCMP.cty_nmstct,Charindex('/',OCMP.cty_nmstct) - 1) End,'')
  ,IDT.cht_itemcode
  ,CHT.cht_description
  ,ih.ord_hdrnumber
  ,@Currency as 'Currency'
  ,ivd_wgt = Case isnull(IDT.ivd_type,'') When 'DRP' then ivd_wgt else 0 end
  ,ivd_volume = case isnull(IDT.ivd_type,'') WHen 'DRP' then ivd_volume else 0 end
  ,ivd_wgtunit = Case isnull(IDT.ivd_type,'') When 'DRP' then ivd_wgtunit else '' end
  ,ivd_volunit = Case isnull(IDT.ivd_type,'') When 'DRP' then ivd_volunit else '' end
  ,billunit = case CHT.cht_primary WHen 'Y' Then LBL.name else '' end
   ,@GSTNUMBER	as 'GSTNUMBER'		--PTS 45203
--------------------
,' ' as 'not_text'
,' ' as 'BOL_stop_ref'
----,(select min(not_text) from notes where  not_type = 'B' and  nre_tablekey = cast(ih.ord_hdrnumber as varchar(18)) and  not_sequence = (select min(not_sequence) from notes where  not_type = 'B' and  nre_tablekey = cast(ih.ord_hdrnumber as varchar(18)))) 'not_text'
----,(select min(REF_NUMBER) from referencenumber where referencenumber.ord_hdrnumber = ih.ord_hdrnumber and REF_TABLE = 'freightdetail' AND REF_TYPE = 'BL#' and REF_SEQUENCE = (SELECT MIN(REF_SEQUENCE) FROM referencenumber  WHERE referencenumber.ord_hdrnumber = ih.ord_hdrnumber)) as 'BOL_stop_ref'
-------------------- 
,ivh_quantity
 ,ISNULL(BCMP.cmp_mbgroup, '') as 'cmp_mbgroup'
,CONSIGNEE_ID = Case IsNull(ivh_showcons,'UNKNOWN') When 'UNKNOWN' Then 'N/A' Else ivh_showcons  End
  ,CONSIGNEE_name = IsNull(CCMP.cmp_name,'')
  ,CONSIGNEE_citystate = IsNull(Case Charindex('/',CCMP.cty_nmstct) 
      When 0 Then CCMP.cty_nmstct 
      Else   Left(CCMP.cty_nmstct,Charindex('/',CCMP.cty_nmstct) - 1) End,'')
,FUEL_SURCHARGE = CASE IDT.cht_itemcode  WHEN 'FSCP'  then ivd_charge 
									     WHEN 'FSCM'  then ivd_charge 
										 WHEN 'FSCF'  then ivd_charge
										 WHEN 'FSCCAN'  then ivd_charge 
										ELSE 0 END  
,NEW_TAX_AMOUNT = IVD_CHARGE 
,ls_freightdetail_bol = ' '
,not_text1 = ' '
,not_text2 = ' '
,not_text3 = ' '
,not_text4 = ' '
,not_text5 = ' '
,ivd_charge = IsNull(ivd_charge,0)
,ivh_consignee				-- PTS 47380
,' ' as ivh_CONSIGNEE_name  -- PTS 47380
-- PTS 47380 5/18 New Req <<start>>
,ivh_trailer	
,evt_trailer2 = (select min(evt_trailer2) from event where event.ord_hdrnumber = IH.ord_hdrnumber and IH.ord_hdrnumber > 0)
,(select min(REF_NUMBER) from referencenumber where referencenumber.ord_hdrnumber = ih.ord_hdrnumber and REF_TABLE = 'orderheader' AND REF_TYPE = 'PO#' and REF_SEQUENCE = (SELECT MIN(REF_SEQUENCE) FROM referencenumber  WHERE referencenumber.ord_hdrnumber = ih.ord_hdrnumber)) as 'PO_Nbr_ref'
-- PTS 47380 5/18 New Req <<end>>
,0 as ll_nooutput		-- PTS 48063 6/30/09 
,Cust_REF_Nbr = ' ' 	-- PTS 48073 6/30/09 

  From invoiceheader IH  
   LEFT OUTER JOIN company BCMP on IH.ivh_billto = BCMP.cmp_id   
   LEFT OUTER JOIN company OCMP on ivh_showshipper = OCMP.cmp_id --ivh_shipper 
	LEFT OUTER JOIN company CCMP on CCMP.cmp_id = ivh_showcons --ivh CONSIGNEE
   LEFT OUTER JOIN company DCMP on ivh_showcons = DCMP.cmp_id    -- get dest name and address for show cons
   LEFT OUTER JOIN companyaddress CAR on ISNULL(IH.car_key,0) = CAR.car_key 
  ,invoicedetail IDT 
   Left  outer join (select labeldefinition,name,abbr From labelfile where labeldefinition in ('WeightUnits','VolumeUnits','CountUnits','TimeUnits')) LBL 
            on LBL.abbr = IDT.ivd_unit    
   LEFT OUTER JOIN company DDCMP on DDCMP.cmp_id = idt.cmp_id   -- get dest info for additional DRPS  
   LEFT OUTER JOIN commodity CMD ON  CMD.cmd_code = IDT.cmd_code  
   Left OUTER JOIN (Select name,abbr From labelfile where labeldefinition = 'RateBy') CTL on CTL.abbr = IsNull(IDT.ivd_rateunit,'')  
   Left OUTER JOIN chargetype CHT on IDT.cht_itemcode  = CHT.cht_itemcode  
   Left OUTER JOIN stops on IDT.stp_number = stops.stp_number   
  Where  IH.ivh_billto = @billto  
    AND IH.ivh_mbstatus = 'RTP'  
    AND IH.ivh_hdrnumber = IDT.ivh_hdrnumber  
    AND (IH.ivh_shipdate between @shipstart AND @shipend )   
   AND (IH.ivh_deliverydate between @delstart AND @delend )   
   AND (@revtype2 in (IH.ivh_revtype2,'UNK')) 
   --------------AND IH.ivh_revtype2 = @revtype2  (for 55 - not needed for 134)
   AND (@revtype3 in (IH.ivh_revtype3,'UNK'))  
   AND (@revtype4 in (IH.ivh_revtype4,'UNK'))   
   AND (@shipper IN(IH.ivh_shipper,'UNKNOWN'))  
   AND (@consignee IN (IH.ivh_consignee,'UNKNOWN'))  
    AND (@Orderby IN (IH.ivh_order_by,'UNKNOWN'))  
    AND (@ivhcompany IN (IH.ivh_company,'UNK')) 
    -------AND IH.ivh_company  = @ivhcompany    (for 55 - not needed for 134)
    And Charindex(IsNull(stp_event,'(('),@NoPrintEvent) = 0 
    And IDT.ivd_charge <> 0  
    --And @Currency = Case IsNull(ivh_currency,'Z-C$')  When 'UNK' Then 'Z-C$' else IsNull(ivh_currency,'Z-C$') END   (for 55 - not needed for 134)
    And @carkey = isnull(IH.car_key,0)
  Order by ShipperID,IH.ivh_invoicenumber,ivd_sequence

------================================================================ FINAGEL WITH PHINEUS --  REFERENCE NUMBERS!!! 

declare @Maxlsrowcnt int
declare @BLloopCnt int
declare @work_CC_IDENTITY int
declare @work_ord_hdrnumber int
declare @next_ord_hdrnumber int
declare @work_string varchar(300)

create table #temp_BL_refnums (lsrowcnt int identity not null primary key clustered, ord_hdrnumber int, REF_NUMBER varchar(30) null) 
-- PTS 48063 adding ll_nooutput for use later (@ end of proc)
--create table #temp_distinct_ord_hdrnumber (lsrowcnt int identity not null primary key clustered, ord_hdrnumber int) 
create table #temp_distinct_ord_hdrnumber (lsrowcnt int identity not null primary key clustered, ord_hdrnumber int, ll_nooutput	int) 

-------------------------------------
insert into #temp_distinct_ord_hdrnumber (ord_hdrnumber)
select  distinct(ord_hdrnumber)  from  #TEMP_MB 

SET @Maxlsrowcnt = ( select max(lsrowcnt) from #temp_distinct_ord_hdrnumber ) 
	
If @Maxlsrowcnt > 0
BEGIN
set @BLloopCnt = 1
While @BLloopCnt <= @Maxlsrowcnt
	BEGIN
		SET @work_ord_hdrnumber = (select ord_hdrnumber from #temp_distinct_ord_hdrnumber where lsrowcnt = @BLloopCnt)
 				
				insert into #temp_BL_refnums (ord_hdrnumber, REF_NUMBER)
				select  top 5 referencenumber.ord_hdrnumber, REF_NUMBER
				from referencenumber
				where  REF_TABLE = 'freightdetail'
				and referencenumber.ord_hdrnumber = @work_ord_hdrnumber
				order by ord_hdrnumber, ref_tablekey, REF_SEQUENCE


	Set @BLloopCnt = @BLloopCnt + 1
	END
END 
---------------------------------------
set @BLloopCnt = 0
SET @Maxlsrowcnt = 0 
set @work_ord_hdrnumber = null
---------------------------------------

----- Need to limit ref #'s PER order ------------ collect this data in loop above.
----insert into #temp_BL_refnums (ord_hdrnumber, REF_NUMBER)
----select  referencenumber.ord_hdrnumber, REF_NUMBER
----from referencenumber
----where  REF_TABLE = 'freightdetail'
--------and referencenumber.ord_hdrnumber = (select min(ord_hdrnumber) from  #TEMP_MB ) 
----and referencenumber.ord_hdrnumber in (select distinct(ord_hdrnumber)  from  #TEMP_MB ) 
----order by ord_hdrnumber, ref_tablekey, REF_SEQUENCE



SET @Maxlsrowcnt = ( select max(lsrowcnt) from #temp_BL_refnums ) 
	
If @Maxlsrowcnt > 0
BEGIN

set @BLloopCnt = 1
set @work_ord_hdrnumber = (select ord_hdrnumber from #temp_BL_refnums where lsrowcnt = @BLloopCnt) 
set @next_ord_hdrnumber = (select ord_hdrnumber from #temp_BL_refnums where lsrowcnt = @BLloopCnt) 

	SET @work_string = ''
	While @BLloopCnt <= @Maxlsrowcnt
	BEGIN
				IF @next_ord_hdrnumber <> @work_ord_hdrnumber
					BEGIN 
						IF LEN(@work_string) > 1 
							begin
								-- clean up the list.		
								SET @work_string = LTRIM(RTRIM(SUBSTRING(@work_string, 1, LEN(@work_string)-1)))
							end

						IF @work_string IS not NULL
							begin			
								set @work_CC_IDENTITY	= (select min(CC_IDENTITY) from  #TEMP_MB  where ord_hdrnumber = @work_ord_hdrnumber) 	
								UPDATE  #TEMP_MB 
								SET ls_freightdetail_bol = LTRIM(RTRIM(@work_string)) 
								--WHERE ord_hdrnumber = @work_ord_hdrnumber
								WHERE CC_IDENTITY = @work_CC_IDENTITY								
								---------------------------------------------------------
								set @work_ord_hdrnumber = @next_ord_hdrnumber
								set @work_string = ''
							end
					END 						

				IF @next_ord_hdrnumber = @work_ord_hdrnumber
					Begin
						Set @work_string = @work_string + (select REF_NUMBER from #temp_BL_refnums where lsrowcnt = @BLloopCnt ) + ', '
						Set @BLloopCnt = @BLloopCnt + 1
						set @next_ord_hdrnumber = (select ord_hdrnumber from #temp_BL_refnums where lsrowcnt = @BLloopCnt) 				
					End	

			-- CATCH the last Write...
			IF @BLloopCnt > @Maxlsrowcnt
				BEGIN 
						IF LEN(@work_string) > 1 
							begin
								-- clean up the list.		
								SET @work_string = LTRIM(RTRIM(SUBSTRING(@work_string, 1, LEN(@work_string)-1)))
							end

						IF @work_string IS not NULL
							begin		

								set @work_CC_IDENTITY	= (select min(CC_IDENTITY) from  #TEMP_MB  where ord_hdrnumber = @work_ord_hdrnumber) 
								UPDATE  #TEMP_MB 
								SET ls_freightdetail_bol = LTRIM(RTRIM(@work_string)) 
								--WHERE ord_hdrnumber = @work_ord_hdrnumber
								WHERE CC_IDENTITY = @work_CC_IDENTITY	
							end
					END 	
	
	END	-- end while
END	-- end IF

------================================================================ FINAGEL WITH PHINEUS --  BILLING NOTES !!!!!

DECLARE @STUPIDCOUNTER INT

create table #temp_BL_note_criteria (lsrowcnt int identity not null primary key clustered, 
								     ivh_invoicenumber  	    varchar (12)  NULL,   
									 ord_hdrnumber  			INT  NULL,    
									 ivh_billto  			    varchar (8)  NULL, 
									 ShipperID  				varchar (8)  NULL,   
									 CONSIGNEE_ID				varchar (8)  NULL,
									 CC_IDENTITY				int null) 

create table #temp_billing_notes	(lsrowcnt int identity not null primary key clustered,
									cc_identity int null,
									not_sequence int null,
									not_text varchar(254) null  )	

SET @Maxlsrowcnt = ( select max(lsrowcnt) from #temp_distinct_ord_hdrnumber ) 
	
If @Maxlsrowcnt > 0
BEGIN
set @BLloopCnt = 1
While @BLloopCnt <= @Maxlsrowcnt
	BEGIN
		SET @work_ord_hdrnumber = (select ord_hdrnumber from #temp_distinct_ord_hdrnumber where lsrowcnt = @BLloopCnt)
 				
				insert into #temp_BL_note_criteria (ivh_invoicenumber, ord_hdrnumber, ivh_billto, ShipperID, CONSIGNEE_ID, CC_IDENTITY )
				select ivh_invoicenumber, ord_hdrnumber, ivh_billto, 	ShipperID 	,  CONSIGNEE_ID, CC_IDENTITY
				FROM #TEMP_MB
				where #TEMP_MB.ord_hdrnumber = @work_ord_hdrnumber
				and CC_IDENTITY = (select min(CC_IDENTITY) from #TEMP_MB where #TEMP_MB.ord_hdrnumber = @work_ord_hdrnumber)

	Set @BLloopCnt = @BLloopCnt + 1
	END
END 


set @BLloopCnt = 0
SET @Maxlsrowcnt = 0 
set @work_ord_hdrnumber = null

SET @Maxlsrowcnt = ( select max(lsrowcnt) from #temp_BL_note_criteria ) 

If @Maxlsrowcnt > 0
BEGIN
set @BLloopCnt = 1
While @BLloopCnt <= @Maxlsrowcnt
	BEGIN
		SET @work_cc_identity = (select  CC_IDENTITY from #temp_BL_note_criteria where lsrowcnt = @BLloopCnt)	
		SET @work_ord_hdrnumber = (select ord_hdrnumber from #temp_BL_note_criteria where lsrowcnt = @BLloopCnt)

		Insert into #temp_billing_notes(cc_identity, not_sequence,not_text )  
		select @work_cc_identity, not_sequence, Ltrim(Rtrim(not_text))
		from  notes
		where  not_type = 'B' 
		and ntb_table = 'invoiceheader'
		and nre_tablekey = (select Ltrim(Rtrim(cast(min(ivh_invoicenumber) as varchar(18)))) from #temp_BL_note_criteria where cc_identity = @work_cc_identity) 
		order by not_sequence

		Insert into #temp_billing_notes(cc_identity, not_sequence,not_text )  
		select @work_cc_identity, not_sequence, Ltrim(Rtrim(not_text))
		from notes
		where  not_type = 'B' 
		and ntb_table = 'orderheader'
		and nre_tablekey = (select Ltrim(Rtrim(cast(min(ord_hdrnumber) as varchar(18)))) from #temp_BL_note_criteria where cc_identity = @work_cc_identity) 
		order by not_sequence

		-- BILL TO COMPANY
		Insert into #temp_billing_notes(cc_identity, not_sequence,not_text )  
		select @work_cc_identity, not_sequence, Ltrim(Rtrim(not_text))
		from notes
		where  not_type = 'B' 
		and ntb_table = 'company'
		and nre_tablekey = (select min(ivh_billto) from #temp_BL_note_criteria where cc_identity = @work_cc_identity) 
		order by not_sequence

		-- SHIPPER COMPANY
		Insert into #temp_billing_notes(cc_identity, not_sequence,not_text )  
		select @work_cc_identity, not_sequence, Ltrim(Rtrim(not_text))
		from notes
		where  not_type = 'B' 
		and ntb_table = 'company'
		and nre_tablekey = (select min(ShipperID) from #temp_BL_note_criteria where cc_identity = @work_cc_identity  AND  ivh_billto <> ShipperID) 
		order by not_sequence

		-- Consignee COMPANY
		Insert into #temp_billing_notes(cc_identity, not_sequence,not_text )  
		select @work_cc_identity, not_sequence, Ltrim(Rtrim(not_text))
		from notes
		where  not_type = 'B' 
		and ntb_table = 'company'
		and nre_tablekey = (select min(CONSIGNEE_ID)  from #temp_BL_note_criteria where cc_identity = @work_cc_identity AND (CONSIGNEE_ID <> ivh_billto) and (CONSIGNEE_ID <> ShipperID) ) 
		order by not_sequence

		-------------------
		delete from #temp_billing_notes where lsrowcnt > (SELECT MIN(lsrowcnt)+ 4 FROM #temp_billing_notes) 

		SET @STUPIDCOUNTER = (SELECT MIN(lsrowcnt) FROM #temp_billing_notes) 
		
		If exists(select not_text from #temp_billing_notes where lsrowcnt = @STUPIDCOUNTER ) 
		BEGIN
			UPDATE #TEMP_MB 
			SET not_text1 = (select LTRIM(RTRIM(not_text)) from #temp_billing_notes where lsrowcnt = @STUPIDCOUNTER   )
			WHERE #TEMP_MB.ord_hdrnumber = @work_ord_hdrnumber
		END	

		If exists(select not_text from #temp_billing_notes where lsrowcnt = @STUPIDCOUNTER + 1 ) 
		BEGIN
			UPDATE #TEMP_MB 
			SET not_text2 = (select LTRIM(RTRIM(not_text)) from #temp_billing_notes where lsrowcnt = @STUPIDCOUNTER + 1 ) 
			WHERE #TEMP_MB.ord_hdrnumber = @work_ord_hdrnumber
		END	

		If exists(select not_text from #temp_billing_notes where lsrowcnt = @STUPIDCOUNTER + 2 ) 
		BEGIN
			UPDATE #TEMP_MB 
			SET not_text3 = (select LTRIM(RTRIM(not_text)) from #temp_billing_notes where lsrowcnt = @STUPIDCOUNTER + 2  )
			WHERE #TEMP_MB.ord_hdrnumber = @work_ord_hdrnumber
		END	

		If exists(select not_text from #temp_billing_notes where lsrowcnt = @STUPIDCOUNTER + 3 ) 
		BEGIN
			UPDATE #TEMP_MB 
			SET not_text4 = (select LTRIM(RTRIM(not_text)) from #temp_billing_notes where lsrowcnt = @STUPIDCOUNTER + 3 ) 
			WHERE #TEMP_MB.ord_hdrnumber = @work_ord_hdrnumber
		END	

		If exists(select not_text from #temp_billing_notes where lsrowcnt = @STUPIDCOUNTER + 4 ) 
		BEGIN
			UPDATE #TEMP_MB 
			SET not_text5 = (select LTRIM(RTRIM(not_text)) from #temp_billing_notes where lsrowcnt = @STUPIDCOUNTER + 4  )
			WHERE #TEMP_MB.ord_hdrnumber = @work_ord_hdrnumber
		END	

	Set @BLloopCnt = @BLloopCnt + 1
	SET @STUPIDCOUNTER = 0
	
	delete from #temp_billing_notes
	
	END
END

------================================================================ FINAGEL WITH PHINEUS - calc NEW_TAX_AMOUNT 

		UPDATE #TEMP_MB 
			SET IVD_CHARGE = 0 
			WHERE cht_primary = 'N' AND cht_basis = 'TAX' and cht_taxtable1 = 'Y'		

		SELECT	CC_IDENTITY		, ivh_invoicenumber, 	ivd_rate, cht_primary, NEW_TAX_AMOUNT, cht_rollintoLH, cht_basis , cht_taxtable1, ivd_charge
				into #TEMP_CALC_NEW_TAXES	
				FROM 	#TEMP_MB 
				WHERE	( cht_primary = 'N' AND cht_taxtable1 = 'Y' AND 	cht_rollintoLH = 0 AND IVD_CHARGE <> 0	) OR
						( cht_primary = 'N' AND cht_basis = 'TAX' and cht_taxtable1 = 'Y' )
						OR  cht_itemcode = 'MIN' 	--PTS48073-7-8-09  include MIN (since they can be cht_primary=Y)	

		UPDATE #TEMP_CALC_NEW_TAXES
		SET NEW_TAX_AMOUNT = ivd_charge * (SELECT MAX(ivd_rate)/100 FROM #TEMP_CALC_NEW_TAXES bb WHERE BB.ivh_invoicenumber = #TEMP_CALC_NEW_TAXES.ivh_invoicenumber AND cht_basis = 'TAX')


		UPDATE #TEMP_MB 
		SET NEW_TAX_AMOUNT = (SELECT NEW_TAX_AMOUNT FROM #TEMP_CALC_NEW_TAXES WHERE #TEMP_CALC_NEW_TAXES.CC_IDENTITY = #TEMP_MB.CC_IDENTITY) 

		UPDATE #TEMP_MB 
			SET NEW_TAX_AMOUNT = 0 WHERE NEW_TAX_AMOUNT IS NULL

		-- report formatting issue...
		Update #TEMP_MB 
		set BOL_stop_ref = null where cht_primary = 'N'


-- PTS 47380 <<start>>
UPDATE #TEMP_MB 
set ivh_CONSIGNEE_name = (select cmp_name from company where cmp_id = #TEMP_MB.ivh_CONSIGNEE)
-- PTS 47380 <<end>>

-- PTS 47380 <<start>>
UPDATE #TEMP_MB 
set ivh_CONSIGNEE_name = (select cmp_name from company where cmp_id = #TEMP_MB.ivh_CONSIGNEE)
-- PTS 47380 <<end>>

-- PTS 47380 5/18 New Req <<start>>
update #TEMP_MB set ivh_trailer = '' where ivh_trailer  = 'UNKNOWN'  

update #TEMP_MB set evt_trailer2 = '' where evt_trailer2 = 'UNKNOWN'  

update #TEMP_MB 
set evt_trailer2 = (select min(evt_trailer2) 
								from #TEMP_MB B 
								where #TEMP_MB.ord_hdrnumber = b.ord_hdrnumber
								and evt_trailer2 <> '')

update #TEMP_MB set evt_trailer2 = ' ' where evt_trailer2 IS NULL 
-- PTS 47380 5/18 New Req <<end>>

------================================================================  Set Instead of PO# use whatever. PTS 48073 <<start>>
create table #temp_CUST_ref  (lsrowcnt int identity not null primary key clustered, ord_hdrnumber int, REF_TYPE varchar(6), REF_NUMBER varchar(30) null) 

SET @Maxlsrowcnt = ( select max(lsrowcnt) from #temp_distinct_ord_hdrnumber ) 
	
If @Maxlsrowcnt > 0
BEGIN
set @BLloopCnt = 1
While @BLloopCnt <= @Maxlsrowcnt
	BEGIN
		SET @work_ord_hdrnumber = (select ord_hdrnumber from #temp_distinct_ord_hdrnumber where lsrowcnt = @BLloopCnt)
 				
				insert into #temp_CUST_ref (ord_hdrnumber, REF_TYPE, REF_NUMBER)
				select top 3 referencenumber.ord_hdrnumber, REF_TYPE, REF_NUMBER
				from referencenumber
				where  REF_TABLE = 'orderheader'
				and referencenumber.ord_hdrnumber = @work_ord_hdrnumber
				order by ord_hdrnumber, REF_SEQUENCE

	Set @BLloopCnt = @BLloopCnt + 1
	END
END 

---------------------------------------
set @BLloopCnt = 0
SET @Maxlsrowcnt = 0 
set @work_ord_hdrnumber = null
---------------------------------------

SET @Maxlsrowcnt = ( select max(lsrowcnt) from #temp_CUST_ref ) 
	
If @Maxlsrowcnt > 0
BEGIN

set @BLloopCnt = 1
set @work_ord_hdrnumber = (select ord_hdrnumber from #temp_CUST_ref where lsrowcnt = @BLloopCnt) 
set @next_ord_hdrnumber = (select ord_hdrnumber from #temp_CUST_ref where lsrowcnt = @BLloopCnt) 

	SET @work_string = ''	
	While @BLloopCnt <= @Maxlsrowcnt
	BEGIN
				IF @next_ord_hdrnumber <> @work_ord_hdrnumber
					BEGIN 
						IF LEN(@work_string) > 1 
							begin
								-- clean up the list.		
								SET @work_string = LTRIM(RTRIM(SUBSTRING(@work_string, 1, LEN(@work_string)-1)))
							end

						IF @work_string IS not NULL
							begin			
								set @work_CC_IDENTITY	= (select min(CC_IDENTITY) from  #TEMP_MB  where ord_hdrnumber = @work_ord_hdrnumber) 	
								UPDATE  #TEMP_MB 
								SET Cust_REF_Nbr = LTRIM(RTRIM(@work_string)) 
								--WHERE ord_hdrnumber = @work_ord_hdrnumber
								WHERE CC_IDENTITY = @work_CC_IDENTITY								
								---------------------------------------------------------
								set @work_ord_hdrnumber = @next_ord_hdrnumber
								set @work_string = ''
							end
					END 						

				IF @next_ord_hdrnumber = @work_ord_hdrnumber
					Begin						
						Set @work_string = @work_string + (select REF_TYPE + ': ' + REF_NUMBER from #temp_CUST_ref  where lsrowcnt = @BLloopCnt ) + ', '
						Set @BLloopCnt = @BLloopCnt + 1
						set @next_ord_hdrnumber = (select ord_hdrnumber from #temp_CUST_ref  where lsrowcnt = @BLloopCnt) 				
					End	

			-- CATCH the last Write...
			IF @BLloopCnt > @Maxlsrowcnt
				BEGIN 
						IF LEN(@work_string) > 1 
							begin
								-- clean up the list.		
								SET @work_string = LTRIM(RTRIM(SUBSTRING(@work_string, 1, LEN(@work_string)-1)))
							end

						IF @work_string IS not NULL
							begin		

								set @work_CC_IDENTITY	= (select min(CC_IDENTITY) from  #TEMP_MB  where ord_hdrnumber = @work_ord_hdrnumber) 
								UPDATE  #TEMP_MB 
								SET Cust_REF_Nbr = LTRIM(RTRIM(@work_string)) 
								--WHERE ord_hdrnumber = @work_ord_hdrnumber
								WHERE CC_IDENTITY = @work_CC_IDENTITY	
							end
					END 	
	
	END	-- end while
END	-- end IF
------================================================================ Instead of PO# PTS 48073 <<end>>

------================================================================  Set ll_NoOutput  PTS 48063
------Identify records For AutoPay we DON'T want the inv to produce output If there are no accessorial or line item charges.
------PTS 48063 If @ll_nooutput = 1 THEN PRINT(default).  If @ll_nooutput = 0 THEN DO NOT PRINT.
--PTS48073-7-8-09 also include OR...= 'MIN' in the select.
update #temp_distinct_ord_hdrnumber
	set ll_nooutput = 1 
	where ord_hdrnumber in ( select distinct(ord_hdrnumber) from #TEMP_MB where ( cht_primary = 'N' AND cht_itemcode <> 'GST' ) OR  cht_itemcode = 'MIN' ) 

update #TEMP_MB 
set ll_nooutput = 1 
where ord_hdrnumber in ( select distinct(ord_hdrnumber) from #temp_distinct_ord_hdrnumber where ll_nooutput = 1 ) 
------================================================================ RETURN FINAL RESULTS

SELECT * FROM #TEMP_MB 


DROP TABLE #TEMP_CALC_NEW_TAXES
DROP TABLE #TEMP_MB 
DROP table #temp_BL_refnums 
DROP table #temp_distinct_ord_hdrnumber
DROP table #temp_BL_note_criteria
DROP table #temp_billing_notes
DROP table #temp_CUST_ref
GO
GRANT EXECUTE ON  [dbo].[d_masterbill135_sp] TO [public]
GO
