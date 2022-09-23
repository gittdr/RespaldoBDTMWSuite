SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*  
   PTS 25191 DPETE  
   This format is used by a company that rates by detail but wants rollintoLH accessorials distributed  
   proportionally across all LH charges and the rate adjusted so that the LH quantity times the rate equals the   
   adjusted charge (Paul's Hauling). Note: The "Destination" location is stop location, not consignee.   
  
PTS25178 manifest is moved to the ivd_refnumber by this PTS, so pick it up from there  
PTS26481 DPETE add ivh_company as a selection criteria  
DPETE 27157 do not return rows that match the events in the GI setting InvoiceNoPrintEvent  
PTS27221 DPETE add group by revtype2 to separate docs by freight type, return revtype2
PTS27641 DPETE eliminate zero charge lines
PTS27735 Add the shipper company ID,Name and city to the format, group by ID. Add the invoice comment (remark)
    remove CRLF CR/LF from remark
    PTS27884 Add cht_itemcode and description
PTS27908    DPETE add ord_hdrnumber to retrieve sub report of stop ref numbers, pass currency so report can
     be separated by currency
PTS27908 go back to currency code, anme is fixed by Great Plains and cnanot be used
PTS30826 DPETE occasionally multiple detail rows are returned (found related to multiple SID ref numbers per stop)
PTS30355 DPETE add-on #1 add total volume or total weight to the printout, bring back bill unit types
DPETE PTS 30355 Add-on #2 display showcons and showshipper info
PTS30355 add company alt address for selection and use
PTS 32284 DPETE mb number not printing on format
PTS 32764 DPETE print total bill quantity for line haul even if count or hours
PTS 34799 Brad Barker sent in change to add DISTINCT to retrieve.
PTS 40260 DPETE recode into main source 4/17/08
pts44904 dpete 10/17/08 customer reports the bill date changes from page to page
DPETE PTS 49521 restore the selection for revtype 1 
*/  
create PROC  [dbo].[d_masterbill55_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8),   
                        @revtype1 varchar(6), @revtype2 varchar(6),@revtype3 varchar(6), @revtype4 varchar(6),@mbstatus varchar(6),  
                        @shipstart datetime,@shipend datetime,@billdate datetime,   
                               @shipper varchar(8), @consignee varchar(8),  
       @delstart datetime, @delend datetime,@orderby varchar(8),@copy tinyint,@ivhcompany varchar(6),@Currency varchar(6),@carkey int) 
 
AS
DECLARE @SIDType varchar(6), @FBCRefType varchar(6),@NoPrintEvent varchar(100)  
  
Select @NoPrintEvent = ','+gi_string1+',' From generalinfo where gi_name = 'InvoiceNoPrintEvent'  
Select @NoPrintEvent = IsNull(@NoPrintEvent,',,') 
Select @Currency = IsNull(@currency,'Z-C$')
If @Currency = 'UNK' Select @Currency = 'Z-C$' 



  
  
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
  
If UPPER(@reprintflag) = 'REPRINT'   
  BEGIN  
  
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
  ,ivd_charge = IsNull(ivd_charge,0)  
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
  ,fbc_manifest = ''  
  ,ivd_sequence 
  ,ivh_revtype2 
  ,ivh_remark = IsNull(Replace(Replace(ivh_remark,Char(13),' '),char(10),''),'')
--  ,ShipperID = Case IsNull(ivh_shipper,'UNKNOWN') When 'UNKNOWN' Then 'N/A' Else ivh_shipper End
  ,ShipperID = Case IsNull(ivh_showshipper,'UNKNOWN') When 'UNKNOWN' Then 'N/A' Else ivh_showshipper End
  ,Shipper_name = IsNull(OCMP.cmp_name,'')
  ,Shipper_citystate = IsNull(Case Charindex('/',OCMP.cty_nmstct) 
      When 0 Then OCMP.cty_nmstct 
      Else   Left(OCMP.cty_nmstct,Charindex('/',OCMP.cty_nmstct) - 1) End,'')
  ,IDT.cht_itemcode
  ,CHT.cht_description
  ,ih.ord_hdrnumber
  ,@Currency
  ,ivd_wgt = Case isnull(IDT.ivd_type,'') When 'DRP' then ivd_wgt else 0 end
  ,ivd_volume = case isnull(IDT.ivd_type,'') WHen 'DRP' then ivd_volume else 0 end
  ,ivd_wgtunit = Case isnull(IDT.ivd_type,'') When 'DRP' then ivd_wgtunit else '' end
  ,ivd_volunit = Case isnull(IDT.ivd_type,'') When 'DRP' then ivd_volunit else '' end
  ,billunit = case CHT.cht_primary WHen 'Y' Then LBL.name else '' end
  From invoiceheader IH  
   LEFT OUTER JOIN company BCMP on BCMP.cmp_id = IH.ivh_billto  
   LEFT OUTER JOIN company OCMP on OCMP.cmp_id = ivh_showshipper --ivh_shipper 
   LEFT OUTER JOIN companyaddress CAR on CAR.car_key = IH.car_key 
   LEFT OUTER JOIN company DCMP on DCMP.cmp_id = ivh_showcons  -- get dest name and address for show cons
  ,invoicedetail IDT 
   Left  outer join (select labeldefinition,name,abbr From labelfile where labeldefinition in ('WeightUnits','VolumeUnits','CountUnits','TimeUnits')) LBL 
            on LBL.abbr = IDT.ivd_unit    
   LEFT OUTER JOIN company DDCMP on DDCMP.cmp_id = idt.cmp_id   -- get dest info for additional DRPS  
   LEFT OUTER JOIN commodity CMD ON  CMD.cmd_code = IDT.cmd_code  
--   LEFT OUTER JOIN (Select ref_number,ref_tablekey from referencenumber where   
 --   ref_table = 'stops' and ref_type = @SIDType) SREF ON SREF.ref_tablekey = IsNull(IDT.stp_number,0)  
 --  LEFT OUTER JOIN (Select ref_number,ref_tablekey from referencenumber where   
 --   ref_table = 'freightdetail' and ref_type = @FBCRefType) MREF ON MREF.ref_tablekey = IsNull(IDT.fgt_number,0)  
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
  ,@billdate  --ivh_billdate  
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
  ,ivd_charge = IsNull(ivd_charge,0)  
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
  ,fbc_manifest = ''  
  ,ivd_sequence 
  ,ivh_revtype2 
  ,ivh_remark = IsNull(Replace(Replace(ivh_remark,Char(13),' '),char(10),''),'')
--  ,ShipperID = Case IsNull(ivh_shipper,'UNKNOWN') When 'UNKNOWN' Then 'N/A' Else ivh_shipper End
  ,ShipperID = Case IsNull(ivh_showshipper,'UNKNOWN') When 'UNKNOWN' Then 'N/A' Else ivh_showshipper End
  ,Shipper_name = IsNull(OCMP.cmp_name,'')
  ,Shipper_citystate = IsNull(Case Charindex('/',OCMP.cty_nmstct) 
      When 0 Then OCMP.cty_nmstct 
      Else   Left(OCMP.cty_nmstct,Charindex('/',OCMP.cty_nmstct) - 1) End,'')
  ,IDT.cht_itemcode
  ,CHT.cht_description
  ,ih.ord_hdrnumber
  ,@Currency
  ,ivd_wgt = Case isnull(IDT.ivd_type,'') When 'DRP' then ivd_wgt else 0 end
  ,ivd_volume = case isnull(IDT.ivd_type,'') WHen 'DRP' then ivd_volume else 0 end
  ,ivd_wgtunit = Case isnull(IDT.ivd_type,'') When 'DRP' then ivd_wgtunit else '' end
  ,ivd_volunit = Case isnull(IDT.ivd_type,'') When 'DRP' then ivd_volunit else '' end
  ,billunit = case CHT.cht_primary WHen 'Y' Then LBL.name else '' end
  From invoiceheader IH  
   LEFT OUTER JOIN company BCMP on IH.ivh_billto = BCMP.cmp_id   
   LEFT OUTER JOIN company OCMP on ivh_showshipper = OCMP.cmp_id --ivh_shipper 
   LEFT OUTER JOIN company DCMP on ivh_showcons = DCMP.cmp_id    -- get dest name and address for show cons
   LEFT OUTER JOIN companyaddress CAR on ISNULL(IH.car_key,0) = CAR.car_key 
  ,invoicedetail IDT 
   Left  outer join (select labeldefinition,name,abbr From labelfile where labeldefinition in ('WeightUnits','VolumeUnits','CountUnits','TimeUnits')) LBL 
            on LBL.abbr = IDT.ivd_unit    
   LEFT OUTER JOIN company DDCMP on DDCMP.cmp_id = idt.cmp_id   -- get dest info for additional DRPS  
   LEFT OUTER JOIN commodity CMD ON  CMD.cmd_code = IDT.cmd_code  
--   LEFT OUTER JOIN (Select ref_number,ref_tablekey from referencenumber where   
 --   ref_table = 'stops' and ref_type = @SIDType) SREF ON SREF.ref_tablekey = IsNull(IDT.stp_number,0)  
 --  LEFT OUTER JOIN (Select ref_number,ref_tablekey from referencenumber where   
 --   ref_table = 'freightdetail' and ref_type = @FBCRefType) MREF ON MREF.ref_tablekey = IsNull(IDT.fgt_number,0)  
   Left OUTER JOIN (Select name,abbr From labelfile where labeldefinition = 'RateBy') CTL on CTL.abbr = IsNull(IDT.ivd_rateunit,'')  
   Left OUTER JOIN chargetype CHT on IDT.cht_itemcode  = CHT.cht_itemcode  
   Left OUTER JOIN stops on IDT.stp_number = stops.stp_number   
  Where  IH.ivh_billto = @billto  
    AND IH.ivh_mbstatus = 'RTP'  
    AND IH.ivh_hdrnumber = IDT.ivh_hdrnumber  
    AND (IH.ivh_shipdate between @shipstart AND @shipend )   
   AND (IH.ivh_deliverydate between @delstart AND @delend )  
   AND (@revtype1 in (IH.ivh_revtype1,'UNK'))   
   --AND (@revtype2 in (IH.ivh_revtype2,'UNK'))  FORMAT BREAKS ON REVTYPE2
   AND IH.ivh_revtype2 = @revtype2  
   AND (@revtype3 in (IH.ivh_revtype3,'UNK'))  
   AND (@revtype4 in (IH.ivh_revtype4,'UNK'))   
   AND (@shipper IN(IH.ivh_shipper,'UNKNOWN'))  
   AND (@consignee IN (IH.ivh_consignee,'UNKNOWN'))  
    AND (@Orderby IN (IH.ivh_order_by,'UNKNOWN'))  
--    AND (@ivhcompany IN (IH.ivh_company,'UNK')) 
    AND IH.ivh_company  = @ivhcompany    
    And Charindex(IsNull(stp_event,'(('),@NoPrintEvent) = 0 
    And IDT.ivd_charge <> 0  
    And @Currency = Case IsNull(ivh_currency,'Z-C$')  When 'UNK' Then 'Z-C$' else IsNull(ivh_currency,'Z-C$') END
    And @carkey = isnull(IH.car_key,0)
  Order by ShipperID,IH.ivh_invoicenumber,ivd_sequence
GO
GRANT EXECUTE ON  [dbo].[d_masterbill55_sp] TO [public]
GO
