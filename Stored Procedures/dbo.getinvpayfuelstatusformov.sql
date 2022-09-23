SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE PROCEDURE [dbo].[getinvpayfuelstatusformov]    
 @mov int    
as     
/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
	PTS19362 DPETE created 10/2/3 Bavarian watns to see, for all orders on a trip, the invoice status,pay status    
		and fuel xfer status onopening the tripfolder if any of the orders is locked for edit.    
 * 11/30/2007.01 - PTS40464 - JGUO - convert old style outer join syntax to ansi outer join syntax.
 * 07/15/2009.01 - PTS48057 - vjh - correct ON clause on right outer join
 *
 **/
    
Select o.ord_number,o.ord_hdrnumber,    
  invoice = IsNull(ivh_invoicenumber,'No invoice'),    
  Invoicetype = Case IsNUll(ivh_definition,'') When '' Then '' When 'LH' Then 'Invoice' When 'RBIL' Then 'Re Bill' When 'CRD' Then 'Credit' End,     
  status = Case ivh_invoicestatus When 'HLD' Then 'On Hold' When 'RTP' Then 'Ready to Print'     
    When  'PRN' Then 'Printed'  When  'PRO' Then ' Invoice Printed' When 'XFR' Then 'Transfer to AR'     
    When 'NTP' Then 'MB Ready to Print' Else '' End,    
  FuelSent = Case When (Select count(*) from legheader where mov_number in (select mov_number from stops s where s.ord_hdrnumber = o.ord_hdrnumber) and lgh_fueltaxstatus = 'PD') > 0    
     Then 'Y' Else 'N' End,    
  Paid = Case  When (Select count(*)     
               From paydetail d,payheader h     
               Where d.ord_hdrnumber = o.ord_hdrnumber     
               and  d.pyh_number > 0     
               and d.pyh_number = h.pyh_pyhnumber     
               and pyh_paystatus = 'COL' ) > 0 Then 'Pay Collected'     
    When (Select count(*) From paydetail Where ord_hdrnumber = o.ord_hdrnumber and  IsNull(pyd_status,'') = 'PND') > 0 Then 'Pay Released'     
    When (Select count(*) From paydetail Where ord_hdrnumber = o.ord_hdrnumber and  IsNull(pyd_status,'') = 'HLD') > 0 Then 'Pay Exists'     
    Else 'Not Paid' end,    
    locked = 'N',  -- to be set in ue_retrieve of ps_w_tripgrid    
    ord_UnlockKey,    
    enterkey = 0    
From  invoiceheader i RIGHT OUTER JOIN orderheader o ON i.ord_hdrnumber = o.ord_hdrnumber  --pts 40463 outer join conversion
   and i.ivh_hdrnumber = (Select max(ivh_hdrnumber) from invoiceheader i2 Where i2.ord_hdrnumber = o.ord_hdrnumber    
								and ivh_definition in ('LH','CRD','RBIL')
						 )    --vjh 48057 this invoice clause needs to be part of the join rather than part of the where clause
Where     
 o.ord_hdrnumber in(Select distinct ord_hdrnumber from stops where stops.mov_number = @mov and ord_hdrnumber > 0)    
   --and i.ord_hdrnumber =* o.ord_hdrnumber    
GO
GRANT EXECUTE ON  [dbo].[getinvpayfuelstatusformov] TO [public]
GO
