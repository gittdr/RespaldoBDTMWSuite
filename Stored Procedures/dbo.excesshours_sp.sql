SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[excesshours_sp] (@lookupby varchar(20),@lookupkey  varchar(25),@whichstatus char(1),@whichrev1 varchar(6)) as
/*  
  
 DPETE 25504 wants to make the excesshours retrievable by order or mov or leg and to select by status  
  @lookupby may be D for driver, O for ord_number, M for mov_number, L for legheader number (anything else retrieves al orders,moves and legs)  
  @lookupkey is the order number (not ird_hdrnumber) or move number or leg number  
  @whichstatus may be 'Y; for accepted, 'R' for rejected or 'N' for not reviewed or anything else for all  
 DPETE 25189 Add LastUpdateBY and LastUpdated and comment
DPETE 28215 add argument for revtype1, return new field xsh_RecAdjType and work field for INI max hours
DPETE 28897 Add pay status from asset assignment record so terminal manager can tell if trip has been computed
  
 if @pl_ordhdrnumber > 0   
  select   
  excesshours.pyd_number,excesshours.pyh_number,excesshours.lgh_number,excesshours.asgn_number,excesshours.asgn_type,excesshours.asgn_id,  
  excesshours.ivd_number,excesshours.pyd_prorap,excesshours.pyd_payto,excesshours.pyt_itemcode,excesshours.mov_number,  
  excesshours.pyd_description,excesshours.pyr_ratecode,excesshours.pyd_quantity,excesshours.pyd_rateunit,excesshours.pyd_unit,  
  excesshours.pyd_rate,excesshours.pyd_amount,excesshours.pyd_pretax,excesshours.pyd_glnum,excesshours.pyd_currency,  
  excesshours.pyd_currencydate,excesshours.pyd_status,excesshours.pyd_refnumtype,excesshours.pyd_refnum,excesshours.pyh_payperiod,  
  excesshours.pyd_workperiod,excesshours.lgh_startpoint,excesshours.lgh_startcity,excesshours.lgh_endpoint,  
  excesshours.lgh_endcity,excesshours.ivd_payrevenue,excesshours.pyd_revenueratio,excesshours.pyd_lessrevenue,  
  excesshours.pyd_payrevenue,excesshours.pyd_transdate,excesshours.pyd_minus,excesshours.pyd_sequence,excesshours.std_number,  
  excesshours.pyd_loadstate,excesshours.pyd_xrefnumber,excesshours.ord_hdrnumber,excesshours.pyt_fee1,excesshours.pyt_fee2,  
  excesshours.pyd_grossamount,excesshours.pyd_adj_flag,excesshours.pyd_updatedby,excesshours.psd_id,excesshours.pyd_transferdate,  
  excesshours.pyd_exportstatus,excesshours.pyd_releasedby,excesshours.cht_itemcode,excesshours.pyd_billedweight,  
  excesshours.tar_tarriffnumber,excesshours.psd_batch_id,excesshours.pyd_updsrc,excesshours.pyd_updatedon,  
  excesshours.pyd_offsetpay_number,excesshours.pyd_credit_pay_flag,excesshours.pyd_ivh_hdrnumber,excesshours.psd_number,  
  excesshours.pyd_ref_invoice,excesshours.pyd_ref_invoicedate,excesshours.pyd_ignoreglreset,excesshours.pyd_authcode,  
  excesshours.pyd_PostProcSource,excesshours.pyd_GPTrans,excesshours.cac_id,excesshours.ccc_id,excesshours.pyd_hourlypaydate,  
  excesshours.xsh_acceptflag,orderheader.ord_number  
  from excesshours ,orderheader  
  where excesshours.ord_hdrnumber = @pl_ordhdrnumber and excesshours.ord_hdrnumber = orderheader.ord_hdrnumber  
 else  
  select   
  excesshours.pyd_number,excesshours.pyh_number,excesshours.lgh_number,excesshours.asgn_number,excesshours.asgn_type,excesshours.asgn_id,  
  excesshours.ivd_number,excesshours.pyd_prorap,excesshours.pyd_payto,excesshours.pyt_itemcode,excesshours.mov_number,  
  excesshours.pyd_description,excesshours.pyr_ratecode,excesshours.pyd_quantity,excesshours.pyd_rateunit,excesshours.pyd_unit,  
  excesshours.pyd_rate,excesshours.pyd_amount,excesshours.pyd_pretax,excesshours.pyd_glnum,excesshours.pyd_currency,  
  excesshours.pyd_currencydate,excesshours.pyd_status,excesshours.pyd_refnumtype,excesshours.pyd_refnum,excesshours.pyh_payperiod,  
  excesshours.pyd_workperiod,excesshours.lgh_startpoint,excesshours.lgh_startcity,excesshours.lgh_endpoint,  
  excesshours.lgh_endcity,excesshours.ivd_payrevenue,excesshours.pyd_revenueratio,excesshours.pyd_lessrevenue,  
  excesshours.pyd_payrevenue,excesshours.pyd_transdate,excesshours.pyd_minus,excesshours.pyd_sequence,excesshours.std_number,  
  excesshours.pyd_loadstate,excesshours.pyd_xrefnumber,excesshours.ord_hdrnumber,excesshours.pyt_fee1,excesshours.pyt_fee2,  
  excesshours.pyd_grossamount,excesshours.pyd_adj_flag,excesshours.pyd_updatedby,excesshours.psd_id,excesshours.pyd_transferdate,  
  excesshours.pyd_exportstatus,excesshours.pyd_releasedby,excesshours.cht_itemcode,excesshours.pyd_billedweight,  
  excesshours.tar_tarriffnumber,excesshours.psd_batch_id,excesshours.pyd_updsrc,excesshours.pyd_updatedon,  
  excesshours.pyd_offsetpay_number,excesshours.pyd_credit_pay_flag,excesshours.pyd_ivh_hdrnumber,excesshours.psd_number,  
  excesshours.pyd_ref_invoice,excesshours.pyd_ref_invoicedate,excesshours.pyd_ignoreglreset,excesshours.pyd_authcode,  
  excesshours.pyd_PostProcSource,excesshours.pyd_GPTrans,excesshours.cac_id,excesshours.ccc_id,excesshours.pyd_hourlypaydate,  
  excesshours.xsh_acceptflag,orderheader.ord_number  
  from excesshours ,orderheader  
  where excesshours.ord_hdrnumber = orderheader.ord_hdrnumber and IsNull(xsh_acceptflag,'N') = 'N'  
*/  
Declare   @ordhdrnumber int  
	, @xstypes VARCHAR(64)

IF LEN(@lookupby) = 2 AND RIGHT(@lookupby, 1) = 'X'
	BEGIN
	SELECT @xstypes = gi_string1 + ','
	FROM generalinfo
	WHERE gi_name = 'ExcessHoursPayTypes'
	SELECT @lookupby = LEFT(@lookupby, 1)
	END
ELSE
	SELECT @xstypes = ''




If @lookupby = 'M'  
select   
  excesshours.pyd_number,excesshours.pyh_number,excesshours.lgh_number,excesshours.asgn_number,excesshours.asgn_type,excesshours.asgn_id,  
  excesshours.ivd_number,excesshours.pyd_prorap,excesshours.pyd_payto,excesshours.pyt_itemcode,excesshours.mov_number,  
  excesshours.pyd_description,excesshours.pyr_ratecode,excesshours.pyd_quantity,excesshours.pyd_rateunit,excesshours.pyd_unit,  
  excesshours.pyd_rate,excesshours.pyd_amount,excesshours.pyd_pretax,excesshours.pyd_glnum,excesshours.pyd_currency,  
  excesshours.pyd_currencydate
  ,pyd_status = Case IsNull(paydetail.pyd_Status,'NULL') 
     When 'NULL' Then excesshours.pyd_status 
     Else paydetail.pyd_status
     End
  ,excesshours.pyd_refnumtype,excesshours.pyd_refnum,excesshours.pyh_payperiod,  
  excesshours.pyd_workperiod,excesshours.lgh_startpoint,excesshours.lgh_startcity,excesshours.lgh_endpoint,  
  excesshours.lgh_endcity,excesshours.ivd_payrevenue,excesshours.pyd_revenueratio,excesshours.pyd_lessrevenue,  
  excesshours.pyd_payrevenue,excesshours.pyd_transdate,excesshours.pyd_minus,excesshours.pyd_sequence,excesshours.std_number,  
  excesshours.pyd_loadstate,excesshours.pyd_xrefnumber,excesshours.ord_hdrnumber,excesshours.pyt_fee1,excesshours.pyt_fee2,  
  excesshours.pyd_grossamount,excesshours.pyd_adj_flag,excesshours.pyd_updatedby,excesshours.psd_id,excesshours.pyd_transferdate,  
  excesshours.pyd_exportstatus,excesshours.pyd_releasedby,excesshours.cht_itemcode,excesshours.pyd_billedweight,  
  excesshours.tar_tarriffnumber,excesshours.psd_batch_id,excesshours.pyd_updsrc,excesshours.pyd_updatedon,  
  excesshours.pyd_offsetpay_number,excesshours.pyd_credit_pay_flag,excesshours.pyd_ivh_hdrnumber,excesshours.psd_number,  
  excesshours.pyd_ref_invoice,excesshours.pyd_ref_invoicedate,excesshours.pyd_ignoreglreset,excesshours.pyd_authcode,  
  excesshours.pyd_PostProcSource,excesshours.pyd_GPTrans,excesshours.cac_id,excesshours.ccc_id,excesshours.pyd_hourlypaydate,  
  xsh_acceptflag = IsNull(excesshours.xsh_acceptflag,'N'),orderheader.ord_number 
    ,lgh_startcty_nmstct,lgh_endcty_nmstct,lgh_startdate,LookupBy = @lookupBy, LookupKey = @LookupKey ,xsh_LastUpdateBy = IsNull(xsh_LastUpdateBy,''),
  xsh_LastUpdated = IsNull(xsh_LastUpdated,'1950-01-01 00:00') ,xsh_comment  
	, orderheader.ord_revtype1, 'RevType1' revtype1
  ,IsNull(xsh_RecAdjType,''),INIMaxHrs=0, SetAccept = '?'
  , trippaystatus = IsNull(asgn.pyd_status,'NPD')

  from excesshours   
       Join orderheader on orderheader.ord_hdrnumber = excesshours.ord_hdrnumber  
       Join legheader on legheader.lgh_number = excesshours.lgh_number
       Left Outer Join paydetail on paydetail.pyd_number = excesshours.pyd_number
       Left Outer Join assetassignment asgn on asgn.lgh_number = excesshours.lgh_number 
             and asgn.asgn_type = excesshours.asgn_type
             and asgn.asgn_id = excesshours.asgn_id  
    Where   
    excesshours.mov_number =  @lookupkey   
    and xsh_acceptflag = Case @whichstatus   
      When 'Y' Then 'Y'  
      When 'R' Then 'R'  
      When 'N' Then 'N'  
      Else xsh_acceptflag  
      End  
   AND (CHARINDEX(excesshours.pyt_itemcode, @xstypes) > 0 OR @xstypes = '')
   And orderheader.ord_revtype1 = Case @whichrev1 WHen 'UNK' Then orderheader.ord_revtype1 Else @whichrev1 End
If @lookupby = 'L'  
select   
  excesshours.pyd_number,excesshours.pyh_number,excesshours.lgh_number,excesshours.asgn_number,excesshours.asgn_type,excesshours.asgn_id,  
  excesshours.ivd_number,excesshours.pyd_prorap,excesshours.pyd_payto,excesshours.pyt_itemcode,excesshours.mov_number,  
  excesshours.pyd_description,excesshours.pyr_ratecode,excesshours.pyd_quantity,excesshours.pyd_rateunit,excesshours.pyd_unit,  
  excesshours.pyd_rate,excesshours.pyd_amount,excesshours.pyd_pretax,excesshours.pyd_glnum,excesshours.pyd_currency,  
  excesshours.pyd_currencydate
  ,pyd_status = Case IsNull(paydetail.pyd_Status,'NULL') 
     When 'NULL' Then excesshours.pyd_status 
     Else paydetail.pyd_status
     End
  ,excesshours.pyd_refnumtype,excesshours.pyd_refnum,excesshours.pyh_payperiod,  
  excesshours.pyd_workperiod,excesshours.lgh_startpoint,excesshours.lgh_startcity,excesshours.lgh_endpoint,  
  excesshours.lgh_endcity,excesshours.ivd_payrevenue,excesshours.pyd_revenueratio,excesshours.pyd_lessrevenue,  
  excesshours.pyd_payrevenue,excesshours.pyd_transdate,excesshours.pyd_minus,excesshours.pyd_sequence,excesshours.std_number,  
  excesshours.pyd_loadstate,excesshours.pyd_xrefnumber,excesshours.ord_hdrnumber,excesshours.pyt_fee1,excesshours.pyt_fee2,  
  excesshours.pyd_grossamount,excesshours.pyd_adj_flag,excesshours.pyd_updatedby,excesshours.psd_id,excesshours.pyd_transferdate,  
  excesshours.pyd_exportstatus,excesshours.pyd_releasedby,excesshours.cht_itemcode,excesshours.pyd_billedweight,  
  excesshours.tar_tarriffnumber,excesshours.psd_batch_id,excesshours.pyd_updsrc,excesshours.pyd_updatedon,  
  excesshours.pyd_offsetpay_number,excesshours.pyd_credit_pay_flag,excesshours.pyd_ivh_hdrnumber,excesshours.psd_number,  
  excesshours.pyd_ref_invoice,excesshours.pyd_ref_invoicedate,excesshours.pyd_ignoreglreset,excesshours.pyd_authcode,  
  excesshours.pyd_PostProcSource,excesshours.pyd_GPTrans,excesshours.cac_id,excesshours.ccc_id,excesshours.pyd_hourlypaydate,  
  xsh_acceptflag = IsNull(excesshours.xsh_acceptflag,'N'),orderheader.ord_number  
    ,lgh_startcty_nmstct,lgh_endcty_nmstct,lgh_startdate,LookupBy = @lookupBy, LookupKey = @LookupKey,xsh_LastUpdateBy = IsNull(xsh_LastUpdateBy,''),
  xsh_LastUpdated = IsNull(xsh_LastUpdated,'1950-01-01 00:00'),xsh_comment   
	, orderheader.ord_revtype1, 'RevType1' revtype1
  ,IsNull(xsh_RecAdjType,''),INIMaxHrs=0, SetAccept = '?'
  , trippaystatus = IsNull(asgn.pyd_status,'NPD')
  From excesshours   
        Join orderheader on orderheader.ord_hdrnumber = excesshours.ord_hdrnumber  
        Join legheader on legheader.lgh_number = excesshours.lgh_number 
        Left Outer Join paydetail on paydetail.pyd_number = excesshours.pyd_number
        Left Outer Join assetassignment asgn on asgn.lgh_number = excesshours.lgh_number 
             and asgn.asgn_type = excesshours.asgn_type
             and asgn.asgn_id = excesshours.asgn_id    
    Where excesshours.lgh_number =  @lookupkey   
    and xsh_acceptflag = Case @whichstatus   
      When 'Y' Then 'Y'  
      When 'R' Then 'R'  
      When 'N' Then 'N'  
      Else xsh_acceptflag  
      End  
   AND (CHARINDEX(excesshours.pyt_itemcode, @xstypes) > 0 OR @xstypes = '')
   And orderheader.ord_revtype1 = Case @whichrev1 WHen 'UNK' Then orderheader.ord_revtype1 Else @whichrev1 End
If @lookupby = 'O'  
BEGIN  
  Select @ordhdrnumber = ord_hdrnumber from orderheader Where ord_number = @Lookupkey  
  Select  
  excesshours.pyd_number,excesshours.pyh_number,excesshours.lgh_number,excesshours.asgn_number,excesshours.asgn_type,excesshours.asgn_id,  
  excesshours.ivd_number,excesshours.pyd_prorap,excesshours.pyd_payto,excesshours.pyt_itemcode,excesshours.mov_number,  
  excesshours.pyd_description,excesshours.pyr_ratecode,excesshours.pyd_quantity,excesshours.pyd_rateunit,excesshours.pyd_unit,  
  excesshours.pyd_rate,excesshours.pyd_amount,excesshours.pyd_pretax,excesshours.pyd_glnum,excesshours.pyd_currency,  
  excesshours.pyd_currencydate
  ,pyd_status = Case IsNull(paydetail.pyd_Status,'NULL') 
     When 'NULL' Then excesshours.pyd_status 
     Else paydetail.pyd_status
     End
  ,excesshours.pyd_refnumtype,excesshours.pyd_refnum,excesshours.pyh_payperiod,  
  excesshours.pyd_workperiod,excesshours.lgh_startpoint,excesshours.lgh_startcity,excesshours.lgh_endpoint,  
  excesshours.lgh_endcity,excesshours.ivd_payrevenue,excesshours.pyd_revenueratio,excesshours.pyd_lessrevenue,  
  excesshours.pyd_payrevenue,excesshours.pyd_transdate,excesshours.pyd_minus,excesshours.pyd_sequence,excesshours.std_number,  
  excesshours.pyd_loadstate,excesshours.pyd_xrefnumber,excesshours.ord_hdrnumber,excesshours.pyt_fee1,excesshours.pyt_fee2,  
  excesshours.pyd_grossamount,excesshours.pyd_adj_flag,excesshours.pyd_updatedby,excesshours.psd_id,excesshours.pyd_transferdate,  
  excesshours.pyd_exportstatus,excesshours.pyd_releasedby,excesshours.cht_itemcode,excesshours.pyd_billedweight,  
  excesshours.tar_tarriffnumber,excesshours.psd_batch_id,excesshours.pyd_updsrc,excesshours.pyd_updatedon,  
  excesshours.pyd_offsetpay_number,excesshours.pyd_credit_pay_flag,excesshours.pyd_ivh_hdrnumber,excesshours.psd_number,  
  excesshours.pyd_ref_invoice,excesshours.pyd_ref_invoicedate,excesshours.pyd_ignoreglreset,excesshours.pyd_authcode,  
  excesshours.pyd_PostProcSource,excesshours.pyd_GPTrans,excesshours.cac_id,excesshours.ccc_id,excesshours.pyd_hourlypaydate,  
  xsh_acceptflag = IsNull(excesshours.xsh_acceptflag,'N'),ord_number = IsNull((Select ord_number From orderheader Where ord_hdrnumber = Excesshours.ord_hdrnumber),'')  
    ,lgh_startcty_nmstct,lgh_endcty_nmstct,lgh_startdate,LookupBy = @lookupBy, LookupKey = @LookupKey,xsh_LastUpdateBy = IsNull(xsh_LastUpdateBy,''),
  xsh_LastUpdated = IsNull(xsh_LastUpdated,'1950-01-01 00:00'),xsh_comment     
	, orderheader.ord_revtype1, 'RevType1' revtype1
  ,IsNull(xsh_RecAdjType,''),INIMaxHrs=0, SetAccept = '?'
  , trippaystatus = IsNull(asgn.pyd_status,'NPD')
  From (Select distinct lgh_number From Stops Where mov_number in (Select distinct mov_number From stops s2 Where s2.ord_hdrnumber = @ordhdrnumber)) LEGS  
      Join Excesshours on excesshours.lgh_number = LEGS.lgh_number
      Left Outer Join paydetail on paydetail.pyd_number = excesshours.pyd_number
      Left Outer Join assetassignment asgn on asgn.lgh_number = excesshours.lgh_number 
             and asgn.asgn_type = excesshours.asgn_type
             and asgn.asgn_id = excesshours.asgn_id      
      Join legheader on legheader.lgh_number = LEGS.lgh_number  
      Join orderheader on orderheader.ord_hdrnumber = excesshours.ord_hdrnumber   
    Where   xsh_acceptflag = Case @whichstatus   
      When 'Y' Then 'Y'  
      When 'R' Then 'R'  
      When 'N' Then 'N'  
      Else xsh_acceptflag  
      End  
   AND (CHARINDEX(excesshours.pyt_itemcode, @xstypes) > 0 OR @xstypes = '')
   And orderheader.ord_revtype1 = Case @whichrev1 WHen 'UNK' Then orderheader.ord_revtype1 Else @whichrev1 End
END  
  
If @lookupby = 'D'  
select   
  excesshours.pyd_number,excesshours.pyh_number,excesshours.lgh_number,excesshours.asgn_number,excesshours.asgn_type,excesshours.asgn_id,  
  excesshours.ivd_number,excesshours.pyd_prorap,excesshours.pyd_payto,excesshours.pyt_itemcode,excesshours.mov_number,  
  excesshours.pyd_description,excesshours.pyr_ratecode,excesshours.pyd_quantity,excesshours.pyd_rateunit,excesshours.pyd_unit,  
  excesshours.pyd_rate,excesshours.pyd_amount,excesshours.pyd_pretax,excesshours.pyd_glnum,excesshours.pyd_currency,  
  excesshours.pyd_currencydate
  ,pyd_status = Case IsNull(paydetail.pyd_Status,'NULL') 
     When 'NULL' Then excesshours.pyd_status 
     Else paydetail.pyd_status
     End
  ,excesshours.pyd_refnumtype,excesshours.pyd_refnum,excesshours.pyh_payperiod,  
  excesshours.pyd_workperiod,excesshours.lgh_startpoint,excesshours.lgh_startcity,excesshours.lgh_endpoint,  
  excesshours.lgh_endcity,excesshours.ivd_payrevenue,excesshours.pyd_revenueratio,excesshours.pyd_lessrevenue,  
  excesshours.pyd_payrevenue,excesshours.pyd_transdate,excesshours.pyd_minus,excesshours.pyd_sequence,excesshours.std_number,  
  excesshours.pyd_loadstate,excesshours.pyd_xrefnumber,excesshours.ord_hdrnumber,excesshours.pyt_fee1,excesshours.pyt_fee2,  
  excesshours.pyd_grossamount,excesshours.pyd_adj_flag,excesshours.pyd_updatedby,excesshours.psd_id,excesshours.pyd_transferdate,  
  excesshours.pyd_exportstatus,excesshours.pyd_releasedby,excesshours.cht_itemcode,excesshours.pyd_billedweight,  
  excesshours.tar_tarriffnumber,excesshours.psd_batch_id,excesshours.pyd_updsrc,excesshours.pyd_updatedon,  
  excesshours.pyd_offsetpay_number,excesshours.pyd_credit_pay_flag,excesshours.pyd_ivh_hdrnumber,excesshours.psd_number,  
  excesshours.pyd_ref_invoice,excesshours.pyd_ref_invoicedate,excesshours.pyd_ignoreglreset,excesshours.pyd_authcode,  
  excesshours.pyd_PostProcSource,excesshours.pyd_GPTrans,excesshours.cac_id,excesshours.ccc_id,excesshours.pyd_hourlypaydate,  
  xsh_acceptflag = IsNull(excesshours.xsh_acceptflag,'N'),orderheader.ord_number  
    ,lgh_startcty_nmstct,lgh_endcty_nmstct,lgh_startdate,LookupBy = @lookupBy, LookupKey = @LookupKey,xsh_LastUpdateBy = IsNull(xsh_LastUpdateBy,''),
  xsh_LastUpdated = IsNull(xsh_LastUpdated,'1950-01-01 00:00') ,xsh_comment  
	, orderheader.ord_revtype1, 'RevType1' revtype1
  ,IsNull(xsh_RecAdjType,''),INIMaxHrs=0, SetAccept = '?'
  , trippaystatus = IsNull(asgn.pyd_status,'NPD')
  From excesshours  
      Join orderheader on orderheader.ord_hdrnumber = excesshours.ord_hdrnumber   
      Join legheader on legheader.lgh_number = excesshours.lgh_number
      Left Outer Join paydetail on paydetail.pyd_number = excesshours.pyd_number
      Left Outer Join assetassignment asgn on asgn.lgh_number = excesshours.lgh_number 
             and asgn.asgn_type = excesshours.asgn_type
             and asgn.asgn_id = excesshours.asgn_id     
    Where excesshours.asgn_id = @lookupkey  
    and excesshours.asgn_type = 'DRV'  
    and xsh_acceptflag = Case @whichstatus   
      When 'Y' Then 'Y'  
      When 'R' Then 'R'  
      When 'N' Then 'N'  
      Else xsh_acceptflag  
      End  
   AND (CHARINDEX(excesshours.pyt_itemcode, @xstypes) > 0 OR @xstypes = '')
   And orderheader.ord_revtype1 = Case @whichrev1 WHen 'UNK' Then orderheader.ord_revtype1 Else @whichrev1 End
  
If @lookupby <> 'M' and @lookupby <> 'L' and @lookupby <> 'O' and @lookupby <> 'D'  
select   
  excesshours.pyd_number,excesshours.pyh_number,excesshours.lgh_number,excesshours.asgn_number,excesshours.asgn_type,excesshours.asgn_id,  
  excesshours.ivd_number,excesshours.pyd_prorap,excesshours.pyd_payto,excesshours.pyt_itemcode,excesshours.mov_number,  
  excesshours.pyd_description,excesshours.pyr_ratecode,excesshours.pyd_quantity,excesshours.pyd_rateunit,excesshours.pyd_unit,  
  excesshours.pyd_rate,excesshours.pyd_amount,excesshours.pyd_pretax,excesshours.pyd_glnum,excesshours.pyd_currency,  
  excesshours.pyd_currencydate
  ,pyd_status = Case IsNull(paydetail.pyd_Status,'NULL') 
     When 'NULL' Then excesshours.pyd_status 
     Else paydetail.pyd_status
     End
  ,excesshours.pyd_refnumtype,excesshours.pyd_refnum,excesshours.pyh_payperiod,  
  excesshours.pyd_workperiod,excesshours.lgh_startpoint,excesshours.lgh_startcity,excesshours.lgh_endpoint,  
  excesshours.lgh_endcity,excesshours.ivd_payrevenue,excesshours.pyd_revenueratio,excesshours.pyd_lessrevenue,  
  excesshours.pyd_payrevenue,excesshours.pyd_transdate,excesshours.pyd_minus,excesshours.pyd_sequence,excesshours.std_number,  
  excesshours.pyd_loadstate,excesshours.pyd_xrefnumber,excesshours.ord_hdrnumber,excesshours.pyt_fee1,excesshours.pyt_fee2,  
  excesshours.pyd_grossamount,excesshours.pyd_adj_flag,excesshours.pyd_updatedby,excesshours.psd_id,excesshours.pyd_transferdate,  
  excesshours.pyd_exportstatus,excesshours.pyd_releasedby,excesshours.cht_itemcode,excesshours.pyd_billedweight,  
  excesshours.tar_tarriffnumber,excesshours.psd_batch_id,excesshours.pyd_updsrc,excesshours.pyd_updatedon,  
  excesshours.pyd_offsetpay_number,excesshours.pyd_credit_pay_flag,excesshours.pyd_ivh_hdrnumber,excesshours.psd_number,  
  excesshours.pyd_ref_invoice,excesshours.pyd_ref_invoicedate,excesshours.pyd_ignoreglreset,excesshours.pyd_authcode,  
  excesshours.pyd_PostProcSource,excesshours.pyd_GPTrans,excesshours.cac_id,excesshours.ccc_id,excesshours.pyd_hourlypaydate,  
  xsh_acceptflag = IsNull(excesshours.xsh_acceptflag,'N'),orderheader.ord_number  
    ,lgh_startcty_nmstct,lgh_endcty_nmstct,lgh_startdate,LookupBy = @lookupBy, LookupKey = @LookupKey,xsh_LastUpdateBy = IsNull(xsh_LastUpdateBy,''),
  xsh_LastUpdated = IsNull(xsh_LastUpdated,'1950-01-01 00:00'),xsh_comment   
	, orderheader.ord_revtype1, 'RevType1' revtype1
  ,IsNull(xsh_RecAdjType,''),INIMaxHrs=0, SetAccept = '?'
  , trippaystatus = IsNull(asgn.pyd_status,'NPD')
  From excesshours   
      Join orderheader on orderheader.ord_hdrnumber = excesshours.ord_hdrnumber  
      Join legheader on legheader.lgh_number = excesshours.lgh_number
      Left Outer Join paydetail on paydetail.pyd_number = excesshours.pyd_number
      Left Outer Join assetassignment asgn on asgn.lgh_number = excesshours.lgh_number 
             and asgn.asgn_type = excesshours.asgn_type
             and asgn.asgn_id = excesshours.asgn_id     
    Where   
      xsh_acceptflag = Case @whichstatus   
      When 'Y' Then 'Y'  
      When 'R' Then 'R'  
      When 'N' Then 'N'  
      Else xsh_acceptflag  
      End  
   AND (CHARINDEX(excesshours.pyt_itemcode, @xstypes) > 0 OR @xstypes = '')
   And orderheader.ord_revtype1 = Case @whichrev1 WHen 'UNK' Then orderheader.ord_revtype1 Else @whichrev1 End
  
GO
GRANT EXECUTE ON  [dbo].[excesshours_sp] TO [public]
GO
