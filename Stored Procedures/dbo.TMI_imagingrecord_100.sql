SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

/*
Created for TMI on PTS 15477
Example call 
exec TMI_imagingrecord_100 @ordhdrnumber =67340,@stpnumber =25525

These records are to be created when the trip starts an every time any of the info on the record changes.
If the event has not been completed, don't provide the date.

There is supposed to be one record for each leg, even if the leg has no stops with the order number
on it (as in a relay)

****** REMEMBER RETURNS NOTHING IF ORDER HAS NO ASSETS **********


1/14/02 DPETE Add SCAC Code
DPETE AT request of KM protect fields normally defaulted with IsNull, just in case
1/22/03 TMI requests records only for legs with assets 
6/10/4 dpete 23436 billable empty move resulted in null empty date
7/30/04 DPETE 24142 remove trailer <> UNKNOWN from where clause
*/
Create Procedure [dbo].[TMI_imagingrecord_100] @ordhdrnumber int
As

--ILB 01/10/03 PTS# 15477
--DTS when sql returns messages due to inserts
SET NOCOUNT ON
--ILB 01/10/03

Declare @scac varchar(10),@trctype varchar(12),@trctype2 varchar(12),@trltype varchar(12),@emptydate datetime,@terminalrevtype varchar(6),@ltlflag char(1),@logisticsload char(1),@ordcount smallint
Declare @invoice char(15),@movnumber int,@revstart int,@ordrevtype varchar(10),@revtype varchar(10)

declare @char6 char(6) 
Select @scac = replicate(' ',4)
Select @trctype = UPPER(gi_string1) From generalinfo where gi_name = 'ImagingTractorType'
Select  @trctype = IsNull( @trctype,'TYPE1')
Select @trltype = UPPER(gi_string1) From generalinfo where gi_name = 'ImagingTrailerType'
Select @trltype = IsNull(@trltype,'TYPE1')
Select @trctype2 = UPPER(gi_string1) From generalinfo where gi_name = 'ImagingTractorTypeForPay'
Select @trctype2 = IsNull(@trctype2,'X')
Select @terminalrevtype = Upper(gi_string1) From generalinfo where gi_name = 'ImagingTerminalRevtype'
Select @terminalrevtype = IsNull(@terminalrevtype,'TYPE1')
Select @movnumber = mov_number from orderheader where ord_hdrnumber = @ordhdrnumber

select @char6 = Replicate(' ',6)

-- get scac
SELECT  @SCAC=UPPER(ISNULL(gi_string1, 'SCAC'))
  FROM	generalinfo 
 WHERE	gi_name='SCAC'

-- Is SCAC based on RevType? get from labelfile
SELECT  @revstart = CHARINDEX('REVTYPE',@SCAC,1)

IF @revstart  = 0 
begin
   SELECT @SCAC=substring(@SCAC,1,4)+ Replicate(' ',4 - datalength(substring(@SCAC,1,4)))

end
ELSE
  BEGIN
   SELECT @revtype = SUBSTRING(@SCAC,@revstart,8)

   SELECT @ordrevtype = 
     Case @revtype
       When 'REVTYPE1' Then ord_revtype1
       When 'REVTYPE2' Then ord_revtype2
       When 'REVTYPE3' Then ord_revtype3
       When 'REVTYPE4' Then ord_revtype4
       Else ord_revtype1
     End
   FROM orderheader where ord_hdrnumber = @ordhdrnumber

  
   SELECT @SCAC = isnull(UPPER(edicode),abbr)
   FROM labelfile
   WHERE labeldefinition = @revtype
   AND    abbr = @ordrevtype

   -- handle spaces in edicode field
   IF LEN(RTRIM(@SCAC)) = 0 
       SELECT @SCAC = '????' 

   SELECT @SCAC = SUBSTRING(@SCAC,1,4) + Replicate(' ',4 - Datalength(SUBSTRING(@SCAC,1,4)))

END
-- If trip is complete, set the trailer empty call date (ecalldate) to depart on last drop stop.
If Exists (Select ord_number from orderheader where ord_hdrnumber = @ordhdrnumber and ord_status = 'CMP' )
	 BEGIN
	    Select @emptydate = stp_departuredate From stops where ord_hdrnumber = @ordhdrnumber and stp_sequence = (select max(stp_sequence) from stops where ord_hdrnumber = @ordhdrnumber
           and stp_type = 'DRP')
         -- bilalable empty move
      If @emptydate is Null  
         Select @emptydate = stp_departuredate From stops where ord_hdrnumber = @ordhdrnumber and stp_sequence = (select max(stp_sequence) from stops where ord_hdrnumber = @ordhdrnumber)
            
  END
Else
	Select @emptydate = '19500101'

Select @emptydate = IsNull(@emptydate,'20491231')

Select @invoice =  Min(ivh_invoicenumber) From invoiceheader where Ord_hdrnumber = @ordhdrnumber
Select @invoice = IsNull(@invoice,'')

/*              Collect first stop of each leg on the trip                    */
/* For cross docked orders need to look at stops with the order hdr (XDU AND XDL have ord_hdrnumber*/
/* For split trips need to look at mov to get legs with no PUP or DRP (TMI wants all legs on a relay) */
Create table #leg1 (lgh_number int NULL,stp_number int NULL)

Insert Into #leg1
Select lgh_number,Min(stp_number)
From stops where 
ord_hdrnumber = @ordhdrnumber
Or mov_number = @movnumber
Group by lgh_number

/* assume ltl if there is more than one order on trip */
Select @ordcount = Count(Distinct(ord_hdrnumber)) From stops s,#leg1 l where s.lgh_number = l.lgh_number and ord_hdrnumber > 0

Select IsNull('10002' +
Substring(@scac,1,4) 
+ Case IsNull(ord_subcompany,'UNK') When 'UNKNOWN' Then Replicate(' ',10) When 'UNK' Then Replicate(' ',10)  Else  Convert(char(10),ord_subcompany) End
+ Convert(char(15),IsNull(s.mov_number,0)) 
+ IsNull(o.ord_number,'') + replicate (' ',20 - datalength(IsNull(o.ord_number,'')))
 + Convert( varchar(12),IsNull(s.lgh_number,0)) 
+ replicate(' ',12 - datalength(Convert( varchar(12),IsNull(s.lgh_number,0))))
+ Case IsNull(evt_tractor,'UNKNOWN') When 'UNKNOWN' Then Convert(char(10),IsNull(evt_carrier,'UNKNOWN')) Else convert(char(10),IsNull(evt_tractor,' ')) End  
+ Case IsNull(evt_driver1,'UNKNOWN') When 'UNKNOWN' Then Replicate(' ',10) Else convert(char(10),IsNull(evt_driver1,' ')) End
+ Case IsNull(evt_driver2,'UNKNOWN')When 'UNKNOWN' Then replicate(' ',10) Else convert(char(10),evt_driver2) End 
+ Case IsNull(evt_trailer1,'UNKNOWN') When 'UNKNOWN' then Replicate(' ',25) Else convert(char(25),IsNull(evt_trailer1,' ')) End
+ Case IsNull(evt_trailer2,'UNKNOWN') When 'UNKNOWN' Then Replicate (' ',25) Else convert(char(25),evt_trailer2) End 
+ Convert(char(6),Case IsNull(@trltype,'TYPE1') When 'TYPE2' Then isnull(t.trl_type2, @char6) When 'TYPE3' Then isnull(t.trl_type3, @char6) When 'TYPE4' Then isnull(t.trl_type4, @char6) Else isnull(t.trl_type1, @char6) End) 
+ Convert( char(10),IsNull(ord_bookdate,getdate()),101)+' '+Convert( char(8),IsNull(ord_bookdate,getdate()),108)
+ Convert( char(10),IsNull(ord_startdate,getdate()),101)+' '+Convert( char(8),IsNull(ord_startdate,getdate()),108)
+ replicate (' ',19)   -- tcalldate not required
+ Case IsNull(ord_status,'AVL') When 'CMP' Then Convert( char(10),IsNull(ord_completiondate,getdate()),101)+' '+Convert( char(8),IsNull(ord_completiondate,getdate()),108) Else replicate(' ',19) End
+ Case @emptydate When '1-1-1950' then replicate(' ',19) Else Convert( char(10),@emptydate,101)+' '+Convert( char(8),@emptydate,108) End 
+ @invoice
+ Convert(Char(10),IsNull(ord_billto,' ')) 
+ replicate(' ',10)  -- bill rep
+ Convert(char(50),Substring(Isnull(bc.cmp_name,' '),1,50)) 
+ Convert(char(40),Substring(Isnull(bc.cmp_address1,' '),1,40)) 
+ Convert(char(40),Substring(Isnull(bc.cmp_address2,' '),1,40)) 
+ Case Charindex(',',IsNull(bc.cty_nmstct,' '))  When 0 Then replicate(' ',50) Else Convert(char(50),Substring(bc.cty_nmstct,1,charindex(',',bc.cty_nmstct) - 1)) End
+ Case Charindex(',',IsNull(bc.cty_nmstct,' '))  When 0 Then replicate(' ',25) Else Convert(char(25),Substring(bc.cty_nmstct,charindex(',',bc.cty_nmstct) + 1,2)) End
+ Convert(char(15),SUbstring(Isnull(bc.cmp_zip,' '),1,15)) 
+ Convert(char(50),Substring(Isnull(oc.cmp_name,' '),1,50)) 
+ Case Charindex(',',IsNull(oc.cty_nmstct,' '))  When 0 Then replicate(' ',50) Else Convert(char(50),Substring(oc.cty_nmstct,1,charindex(',',oc.cty_nmstct) - 1)) End
+ Case Charindex(',',IsNull(oc.cty_nmstct,' '))  When 0 Then replicate(' ',25) Else Convert(char(25),Substring(oc.cty_nmstct,charindex(',',oc.cty_nmstct) + 1,2)) End
+ Convert(char(15),SUbstring(Isnull(oc.cmp_zip,' '),1,15)) 
+ Convert(char(50),Substring(Isnull(dc.cmp_name,' '),1,50)) 
+ Case Charindex(',',IsNull(dc.cty_nmstct,' '))  When 0 Then replicate(' ',50) Else Convert(char(50),Substring(dc.cty_nmstct,1,charindex(',',dc.cty_nmstct) - 1)) End
+ Case Charindex(',',IsNull(dc.cty_nmstct,' '))  When 0 Then replicate(' ',25) Else Convert(char(25),Substring(dc.cty_nmstct,charindex(',',dc.cty_nmstct) + 1,2)) End
+ Convert(char(15),SUbstring(Isnull(dc.cmp_zip,' '),1,15)) 
+ Convert(char(1),Case When @ordcount > 1 Then 'Y' Else 'N' End )   -- LTLFLAG
+ Convert(char(6),Case IsNull(@trctype,'TYPE1')  When 'TYPE1' Then IsNull(tc.trc_type1,' ') When 'TYPE2' Then IsNull(tc.trc_type2,' ') When 'TYPE3' Then IsNull(tc.trc_type3,' ') When 'TYPE4' Then IsNull(tc.trc_type4,' ') Else IsNull(tc.trc_type1,' ') End) 
+ Case IsNull(@trctype2,'TYPE1') 
  When 'TYPE1' Then Substring(IsNull(tc.trc_type1,' '),1,1) 
  When 'TYPE2' Then Substring(IsNull(tc.trc_type2,' '),1,1)  
  When 'TYPE3' Then Substring(IsNull(tc.trc_type3,' '),1,1)  
  When 'TYPE4' Then Substring(IsNull(tc.trc_type4,' '),1,1) Else 'M' End
+ Convert(char(10),Case IsNull(ord_thirdpartytype1,'UNKNOWN') When 'UNKNOWN' Then ' ' Else Substring(IsNull(ord_thirdpartytype1,' '),1,10) End) 
+ Convert(char(6),Case IsNull(@terminalrevtype,'TYPE1') When 'TYPE2' Then IsNull(ord_revtype2,' ') When 'TYPE3' Then IsNull(ord_revtype3,' ') When 'TYPE4' Then IsNull(ord_revtype4,' ') Else IsNull(ord_revtype1,' ') End) 
+  'N'   -- Logistics load don't know how to determine
+ replicate(' ',10)  -- misc equipment
+ Convert(char(1), Case IsNull(evt_carrier,'UNKNOWN') When 'UNKNOWN' Then
(Case IsNull(tc.trc_owner,'UNKNOWN') When 'UNKNOWN' Then 'C' Else 'D' End)
 Else 'B' End )
+ Convert(char(1), Case IsNull(evt_carrier,'UNKNOWN') When 'UNKNOWN' Then
(Case IsNull(t.trl_owner,'UNKNOWN')  When 'UNKNOWN' Then 'C' Else 'D' End) 
Else 'B' End )
+ replicate(' ',1)
,
'    '+ord_number)  -- misc eqpt own  */
From orderheader o ,  stops s ,event e ,  
 company bc,
company oc,
company dc ,trailerprofile t, tractorprofile tc

Where o.ord_hdrnumber = @ordhdrnumber
	And s.stp_number in (Select  stp_number from #leg1)
    And e.stp_number = s.stp_number
	 And e.evt_sequence = 1
    And tc.trc_number =* e.evt_tractor
    And t.trl_number =* e.evt_trailer1
    And bc.cmp_id =* ord_billto
    And oc.cmp_id =* ord_originpoint
    And dc.cmp_id =* ord_destpoint
    And ((IsNull(evt_tractor,'UNKNOWN') <> 'UNKNOWN' and IsNull(evt_driver1,'UNKNOWN') <> 'UNKNOWN')
		OR
		IsNull(evt_carrier,'UNKNOWN') <> 'UNKNOWN')


Drop table #leg1
GO
GRANT EXECUTE ON  [dbo].[TMI_imagingrecord_100] TO [public]
GO
