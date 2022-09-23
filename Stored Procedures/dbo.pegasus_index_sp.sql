SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

Create  PROC [dbo].[pegasus_index_sp] @ord_number varchar(12) , @drvid varchar(8), @trcid varchar(8), @trlid varchar(13),@mov int,@RecLimit smallint
AS 

/**
 * 
 * NAME:
 * dbo.pegasus_index_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * See Revision History section
 * 
 *
 * RETURNS:
 * N/A  
 *
 * RESULT SETS: 
 * See SELECT statement.
 *
 * PARAMETERS:
 * 001 - @ord_number varchar(12)
 * 002 - @drvid varchar(8)
 * 003 - @trcid varchar(8)
 * 004 - @trlid varchar(13)
 * 005 - @mov int
 * 006 - @RecLimit smallint
 *
 * REFERENCES:
 * NONE
 * 
 * REVISION HISTORY:
 * 
 * 7/20/2006.01 - History Log (Old Log):
 * 
 *
 * JYANG Written for Pegasus
 * DPETE 13101 add on. fix problems reported by Pegasus, getting error on calling proc. Also clean up other problems 
 * DPETE 14754 6/27/02 Change mpp_type to mpp_type1
 * PTS15660 DPETE 9/27/02 Add mov and reclimit arge to call. It is assumed if order is passed it will beused, else the mov number
 * dpete 9/4/02 Add mov_number to return set per request of CHristie
 * DPETE 17033 1/30/03 Rewrite to handle empty moves, relay legs and cancelled empty moves.
 * DPETE 17361 at Peg request change returned date to mm/dd/ccyy
 * DPETE 17432 Check for valid ord_number or valid move and return fast if not valid
 *    (force an empty return set with an impossible where clause)
 * DPETE 4/23/03 Get 18173 around problem picking up assets from first stop on leg when the leg starts with a BBT
 * DPETE 5/8/3 18173 Tag user field 1 with Y for last leg of trip
 * DPETE 5/9/3 18173 Use GI setting to determine where to search for BL ref number
 * DPETE 18453 Pegasus wants the pay status in user defined field #2  to reflect the pay status for the leg.
 *    (also noticed that the passed assets did not limit the return set, enabled that)
 * DPETE 18668 Need to be able to pass the first ref number if customer requires
 * DPETE PTS 18793 switch the revtype value and return edi code equivalent in next userdefineable (add 10 more user define fields)
 * DPETE PTS 19502 move limitation to number of records down to just above final select (limited orders on a leg to one)
 * DPETE 30781 customer (Falcon) wants to add driver1 alt id to return set
 * DPETE 32585 Not always getting back records
 *
 * 
 * 7/20/2006.01 - PTS33809 - PRB - Created this log and altered the proc to remove ANSI JOINS
 * 7/20/2006.02 - PTS33809 - PRB - Added support for shrinking ref_numbers to 20 characters.  Pegasus can't handle more than
 *                               - 20 or it blows up their process.
 * 9/1/06.03 - PTS 34317 DPETE  - enhance invoice status to include indication of printed or transferred invoice. In addition
 *                  to PND, AVL, and PPD add PRN and XFR
 **/

declare @char20 char(20),
	@char12 char(12),
	@char10 char(10),
	@invoiceno varchar(12),
	@pickupdt  datetime,
	@ordhdrnumber int,
	@lastleg int ,  
 	@seq varchar(20),
	@bol varchar(25) ,
   @revtype varchar(15),
   @trctype varchar(10),
   @minivhhdrnumber int
 

/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */    
Select @seq = gi_string1 From generalinfo Where gi_name = 'ImagingBLSearchSeq'  
Select @seq = (Case @seq When 'ORD/STOP' then @seq When 'STOP/ORD' Then @seq When 'FIRST' Then @seq Else 'FIRST' End)  

Select @char12 = replicate(' ',12)
Select @char20 = replicate(' ',20)
select @drvid = isnull(@drvid,'UNKNOWN')
select @trcid = isnull(@trcid,'UNKNOWN')
select @trlid = isnull(@trlid,'UNKNOWN')
Select @ordhdrnumber = ord_hdrnumber from orderheader where ord_number = @ord_number
Select @ordhdrnumber = IsNull(@ordhdrnumber,0)
Select @mov = IsNull(@mov,0)
Select @RecLimit = IsNull(@RecLimit,9999)
--Set ROWCOUNT @Reclimit
Select @revtype = UPPER(gi_string1) From generalinfo Where gi_name = 'PegIndexRevType'
Select @revtype = IsNull(@revtype,'TYPE1' )  -- default to current unswitched value
Select @revtype = Case @revtype When 'REVTYPE1' Then 'Type1' When 'Revtype2' Then 'TYPE2'
  When 'REVTYPE3' Then 'TYPE3' when 'REVTYPE4' Then 'TYPE4' Else @revtype End
Select @trctype = UPPER(gi_string1) From generalinfo Where gi_name = 'PegIndexTrcType'
Select @trctype = IsNull(@trctype,'TYPE1' )  -- default is tractor type1
Select @trctype = Case @revtype When 'TRCTYPE1' Then 'Type1' When 'TRCTYPE2' Then 'TYPE2'
  When 'TRCTYPE3' Then 'TYPE3' when 'TRCTYPE4' Then 'TYPE4' Else @trctype End


If (@ordhdrnumber = 0 and @ord_number > '') Or 
  ( @mov > 0 and Not Exists (Select lgh_number from stops where mov_number = @mov)) 
 Begin
  --Return
  Select 
   NULL ORDERNO,
   NULL DRIVERCD,
   NULL TRUCK, 
   NULL TRAILER, 
   NULL DRIVERCD2, 
   NULL TERMINAL,
   NULL SHIPPER,
   NULL INVOICENO,
   NULL CONSIGNEE, 
   NULL  SHIPDT ,
   NULL PICKUPDT ,
	NULL REFNO,
   NULL  REFTYPE,
   NULL INVSTATUS, 
   NULL  STATUS,
   NULL  ORIGIN_CITY  , 
	NULL ORIGIN_STATE,
	NULL   DESTINATION_CITY,
	NULL DESTINATION_STATE,
	BILLTOCD = NULL ,
 	 CUSTOMER_NAME =  NULL ,
	REVENUE_TYPE =  NULL ,
   NULL DRIVER_TYPE,
   NULL   LEG_ORIGIN_CITY, 	 
   NULL LEG_ORIGIN_STATE, 
   NULL   LEG_DESTINATION_CITY, 
   NULL LEG_DESTINATION_STATE, 
   NULL  LEG_DRIVER1, 
   NULL  LEG_DRIVER2, 
   NULL  LEG_TRUCK,
   NULL LEG_TRAILER,
   NULL LEG_DELIVERY_DATE,
   NULL USERDEFINEDFIELD1,
   NULL USERDEFINEDFIELD2,
   NULL USERDEFINEDFIELD3,
   NULL USERDEFINEDFIELD4,
   NULL USERDEFINEDFIELD5,
   NULL OWEROPERATOR_CODE,
   NULL MOVE_NUMBER,
   NULL USERDEFINEDFIELD6,
   NULL USERDEFINEDFIELD7,
   NULL USERDEFINEDFIELD8,
   NULL USERDEFINEDFIELD9,
   NULL USERDEFINEDFIELD10,
   NULL USERDEFINEDFIELD11,
   NULL USERDEFINEDFIELD12,
   NULL USERDEFINEDFIELD13,
   NULL USERDEFINEDFIELD14,
   NULL USERDEFINEDFIELD15
   From orderheader where 0 = 1  -- force am empty row with titles important

  Return
 End

Create table #legs (lgh_number int NULL,
startdate char(10) NULL, 
enddate char(10) null,
startcity char(18) null,
endcity char(18) null,
startstate char(2) null,
endstate char(2) null,
startstop int null,
endstop int null,
startcompany char(8) null,
endcompany  char(8) null,
driver char(8) null,
tractor char(8) null,
trailer char(8) null,
driver2 char(8) null,
ord_hdrnumber int null,
drivertype char(6) null,
mov_number char(15) NULL,
legstartdttm datetime null,
lastleg char(1) null,
legsequence datetime null,
legpaystatus varchar(6) null,
trctype char(6) null,
driverotherid char(20) null
)


-- If order given get all legs over which order passes
If @ord_number > ''
 Begin

  Select @minivhhdrnumber = min(ivh_hdrnumber) from invoiceheader where ord_number = @ord_number
  select @minivhhdrnumber = isnull(@minivhhdrnumber,-9)  -- make sure there is no match
  
 
  Select @lastleg = lgh_number from stops
  Where ord_hdrnumber = @ordhdrnumber
	And stp_sequence = (Select max(stp_sequence) From stops where ord_hdrnumber = @ordhdrnumber)

  Insert Into #legs
  Select Distinct lgh_number,'2-1-2000','1-1-2000',replicate(' ',18),replicate(' ',19),replicate(' ',2),replicate(' ',2),
	0,
   0,
   '',
   '',
   driver = IsNull((Select Convert(char(8),Max(evt_driver1))
    From event
    Where stp_number in (Select stp_number from stops s2 Where s2.lgh_number = stops.lgh_number)
    And evt_sequence = 1
	  And evt_driver1 <> 'UNKNOWN'),'UNK     '),
   tractor = IsNull((Select Convert(char(8),Max(evt_tractor))
    From event
     Where stp_number in (Select stp_number from stops s2 Where s2.lgh_number = stops.lgh_number)
     And evt_sequence = 1
	 And evt_tractor <> 'UNKNOWN'),'UNK     '),
  trailer = IsNull((Select Convert(char(8),Max(evt_trailer1))
    From event
    Where stp_number in (Select stp_number from stops s2 Where s2.lgh_number = stops.lgh_number)
    And evt_sequence = 1
	 And evt_trailer1 <> 'UNKNOWN'),'UNK     '),
  driver2 =  IsNull((Select Convert(char(8),Max(evt_driver2 ))
    From event
    Where stp_number in (Select stp_number from stops s2 Where s2.lgh_number = stops.lgh_number)
    And evt_sequence = 1
	And evt_driver2 <> 'UNKNOWN'), 'UNK     '),
   @ordhdrnumber,
   ' ',
   Convert(char(15),mov_number),
   '1-1-1950',
	lastleg = Case lgh_number When @lastleg Then 'Y' Else 'N' End,
	'1-1-1950',
   Case IsNull((Select max(pyd_status) from assetassignment aa where aa.lgh_number = stops.lgh_number),'NPD')
     When 'PPD' Then 'PAID' Else 'NOPD' End,
  'UNK'
 ,''
  From stops Where mov_number in (Select Distinct mov_number From stops Where ord_hdrnumber = @ordhdrnumber)
 End
Else
  -- If move passed get all leg/order combos over the move
  Begin
    Select @lastleg = lgh_number from stops
  	 Where mov_number = @mov
    And stp_arrivaldate = (Select max(stp_arrivaldate) From stops where mov_number = @mov and ord_hdrnumber = 0)

	Insert Into #legs
   Select Distinct lgh_number,'01-01-2000','01-01-2000',replicate(' ',18),replicate(' ',19),replicate(' ',2),replicate(' ',2),
	0,0,'','',
 driver = IsNull((Select Convert(char(8),Max(evt_driver1))
    From event
    Where stp_number in (Select stp_number from stops s2 Where s2.lgh_number = stops.lgh_number)
    And evt_sequence = 1
	  And evt_driver1 <> 'UNKNOWN'),'UNK     '),
   tractor = IsNull((Select Convert(char(8),Max(evt_tractor))
    From event
     Where stp_number in (Select stp_number from stops s2 Where s2.lgh_number = stops.lgh_number)
     And evt_sequence = 1
	 And evt_tractor <> 'UNKNOWN'),'UNK     '),
  trailer = IsNull((Select Convert(char(8),Max(evt_trailer1))
    From event
    Where stp_number in (Select stp_number from stops s2 Where s2.lgh_number = stops.lgh_number)
    And evt_sequence = 1
	 And evt_trailer1 <> 'UNKNOWN'),'UNK     '),
  driver2 =  IsNull((Select Convert(char(8),Max(evt_driver2 ))
    From event
    Where stp_number in (Select stp_number from stops s2 Where s2.lgh_number = stops.lgh_number)
    And evt_sequence = 1
	And evt_driver2 <> 'UNKNOWN'), 'UNK     '),
ord_hdrnumber,' ',Convert(char(15),mov_number),'1-1-1950',
   lastleg = Case lgh_number When @lastleg Then 'Y' Else 'N' End,'1-1-1950',
   Case IsNull((Select max(pyd_status) from assetassignment aa where aa.lgh_number = stops.lgh_number),'NPD')
     When 'PPD' Then 'PAID' Else 'NOPD' End,
   'UNK'
 ,''
   From stops Where mov_number = @Mov

    Delete from #legs where ord_hdrnumber = 0 and exists (select lgh_number From #legs l2 Where l2.lgh_number = #legs.lgh_number
		and l2.ord_hdrnumber > 0)

  End

If @drvid <> 'UNKNOWN' and Len(Rtrim(@drvid)) > 0
   Delete From #legs where driver <> @drvid
If @trcid <> 'UNKNOWN' and Len(Rtrim(@trcid)) > 0
   Delete From #legs where tractor <> @trcid
If @trlid <> 'UNKNOWN' and Len(Rtrim(@trlid)) > 0
   Delete From #legs where trailer <> @trlid

Update #legs
  Set startdate = convert(char(10),stp_arrivaldate,101),
		startstop = stp_number,
		startcity = IsNull(Convert(char(18),cty_name),replicate(' ',18)),
		startstate = Convert(char(2),  Substring(cty_state,1,2)  ),
		startcompany = IsNull(Convert(char(8),cmp_id),replicate(' ',8)),
		legstartdttm = convert(char(10),stp_arrivaldate,101)
  From stops
  RIGHT OUTER JOIN city 
  ON city.cty_code = stp_city
  Where stops.lgh_number = #legs.lgh_number
  And stp_mfh_sequence = (Select min(stp_mfh_sequence) From stops s1 where s1.lgh_number = #legs.lgh_number)
  -- PTS33809 And city.cty_code  =* stp_city

Update #legs
 Set enddate = convert(char(10),stp_arrivaldate,101),
		endstop = stp_number,
		endcity = IsNull(Convert(char(18),cty_name),replicate(' ',18)),
		endstate = Convert(char(2),  Substring(cty_state,1,2)  ),
		endcompany = IsNull(Convert(char(8),cmp_id),replicate(' ',8)),
		legsequence = stp_arrivaldate
  From stops
  RIGHT OUTER JOIN city
  ON city.cty_code = stp_city
  Where stops.lgh_number = #legs.lgh_number
  And stp_mfh_sequence = (Select max(stp_mfh_sequence) From stops s1 where s1.lgh_number = #legs.lgh_number)
  --PTS33809 And city.cty_code  =* stp_city
/* pick up assts one at a time across stops in case of bbt or ebt type stops on leg */

 

Update #legs
 Set drivertype =  Convert(char(6),IsNull(mpp.mpp_type1,'UNK')),driverotherid = convert(char(20),IsNull(mpp_otherid,' '))
 From manpowerprofile mpp
 RIGHT OUTER JOIN #legs
 ON mpp.mpp_id = #legs.driver
 Where #legs.driver is not null
 --PTS33809 And mpp.mpp_id =* #legs.driver

Update #legs
 Set trctype = Convert(char(6),IsNull(
  Case @trctype When 'TYPE2' Then trc_type2 When 'TYPE3' Then trc_type3 When 'TYPE4' Then trc_type4 Else trc_type1 End              
,'UNK'))
From tractorprofile trc
Where trc.trc_number = #legs.tractor

Create table #ords (ord_hdrnumber int null,ord_number char(12) null ,ord_shipper char(8)  null, ord_consignee char(8) null,
origincity char(18) null,destcity char(18) null,originstate char(2) null, deststate char(2) null,
ord_reftype char(12) null,ord_refnum char(20) null,ord_status char(6) null,ord_invoicestatus char(6) null,
invoicenumber char(12) null,ord_revtype1 char(6) null, ord_revtype2 char(6) NULL,ord_revtype3 char(6) null,
ord_revtype4 char(6) null,ord_startdate char(10) null,ord_billto char(8) null,billtoname char(100) null)

Insert into #ords
  Select Distinct stops.ord_hdrnumber,'','','','','','','','','','','','','','','','','','',''
  From #legs,stops
  Where stops.lgh_number = #legs.lgh_number
  And stops.ord_hdrnumber > 0

If @ord_number > ''
 Delete from #ords Where #ords.ord_hdrnumber <> @ordhdrnumber

Update #ords
	Set
	ord_number = convert(char(12),orderheader.ord_number) ,
	ord_shipper = Case Isnull(orderheader.ord_shipper,'UNK     ') When 'UNKNOWN' Then 'UNK     ' 
		Else Convert(char(8),orderheader.ord_shipper) End,
   ord_consignee = Case IsNull(orderheader.ord_consignee,'UNK     ') when 'UNKNOWN' Then 'UNK     ' 
		Else Convert(char(8),orderheader.ord_consignee) End,
	origincity = Convert(char(18),Substring(IsNull(oc.cty_name,' '),1,18)),
	destcity =Convert(char(18),Substring(IsNull(dc.cty_name,' '),1,18)),
	originstate = Convert(char(2),substring(oc.cty_state,1,2)), 
	deststate = Convert(char(2),substring(dc.cty_state,1,2)),
   ord_refnum = Convert(char(20),Substring(Isnull(orderheader.ord_refnum,'UNK'),1,20)),
   ord_reftype = Convert(char(12),Substring(Isnull(orderheader.ord_reftype,' '),1,12)),
	ord_status = convert(char(6),IsNull(orderheader.ord_status,' ')),
   Ord_invoicestatus = case isnull(ivh_invoicestatus,'?') 
      when '?' then Convert(char(6), IsNull(orderheader.ord_invoicestatus,'UNK'))
      when 'PRN' then 'PRN   '
      when 'XFR' then 'XFR   '
      else 'PPD   ' end,
	ord_revtype1 = convert(char(6),IsNull(orderheader.ord_revtype1,'UNK')),
	ord_revtype2 = convert(char(6),IsNull(orderheader.ord_revtype2,'UNK')),
   ord_revtype3 = convert(char(6),IsNull(orderheader.ord_revtype3,'UNK')),
	ord_revtype4 = convert(char(6),IsNull(orderheader.ord_revtype4,'UNK')),
	ord_startdate = convert(char(10),orderheader.ord_startdate,101),
	ord_billto = Convert(char(8),IsNull(orderheader.ord_billto,'UNKNOWN')),
	billtoname = Convert(char(100),IsNull(company.cmp_name,' '))
From orderheader
RIGHT OUTER JOIN city oc
ON oc.cty_code = orderheader.ord_origincity 
RIGHT OUTER JOIN city dc
ON dc.cty_code = orderheader.ord_destcity
RIGHT OUTER JOIN company
ON company.cmp_id = orderheader.ord_billto
LEFT OUTER JOIN invoiceheader on
   orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber and ivh_hdrnumber = @minivhhdrnumber
Where orderheader.ord_hdrnumber = #ords.ord_hdrnumber
--And oc.cty_code =* orderheader.ord_origincity
--And dc.cty_code =* orderheader.ord_destcity
--And company.cmp_id =* orderheader.ord_billto

   Update #ords
	Set 	invoicenumber = Convert(char(12),ivh_invoicenumber)
   From invoiceheader
	Where invoiceheader.ord_hdrnumber = #ords.ord_hdrnumber
   And ivh_hdrnumber = (Select Min(ivh_hdrnumber) from invoiceheader ih2 Where ih2.ord_hdrnumber = #ords.ord_hdrnumber)

Update #ords
  Set invoicenumber = 'UNK'+ Replicate(' ',9)
  Where invoicenumber = ''
 
/*  Code for ref number  */
/* collect Bill of lading ref number*/   
    
   If @seq = 'ORD/STOP'  
    BEGIN  
		Update #ords 
       Set ord_refnum = (  
        --PTS33809 added case was SELECT MIN(ref_number)
        Select oref = CASE
       		   	   WHEN LEN(MIN(ref_number)) <= 20 THEN MIN(ref_number)
       		   	   ELSE SUBSTRING(ISNULL(MIN(ref_number), ''), 1, 20)
       			  END 
        From referencenumber Where ref_table = 'orderheader'   
        and ref_tablekey = #ords.ord_hdrnumber 
        and ref_type in  ('BL#','BOL')  
        and ref_sequence = (Select Min(ref_sequence) From referencenumber Where   
            ref_table = 'orderheader'   
           and ref_tablekey = #ords.ord_hdrnumber and ref_type in ('BL#','BOL'))),
        ord_reftype = 'BL#'
        Where ord_hdrnumber > 0

    
      Update #ords 
       Set ord_refnum = (
       --PTS33809 added case was SELECT MIN(ref_number)
       Select oref = CASE
       		   	   WHEN LEN(MIN(ref_number)) <= 20 THEN MIN(ref_number)
       		   	   ELSE SUBSTRING(ISNULL(MIN(ref_number), ''), 1, 20)
       			  END 
       From referencenumber Where ref_table = 'stops'   
       and ref_tablekey in (select stp_number from stops where stops.ord_hdrnumber =  #ords.ord_hdrnumber)  
       and ref_type in  ('BL#','BOL') 
       and ref_sequence = (Select Min(ref_sequence) From referencenumber Where   
         ref_table = 'stops'   
          and ref_tablekey in (select stp_number from stops where stops.ord_hdrnumber =  #ords.ord_hdrnumber
          and ref_type in  ('BL#','BOL') ) )
			),
		  Ord_reftype = 'BL#'
        Where IsNull(ord_refnum,'') = ''     
  		  and ord_hdrnumber > 0  
  
    END  
  -- Else 

If @seq = 'STOP/ORD' 
    BEGIN  
      Update #ords 
       Set ord_refnum =  (  
       --PTS33809 added case was SELECT MIN(ref_number)
       Select oref = CASE
       		   	   WHEN LEN(MIN(ref_number)) <= 20 THEN MIN(ref_number)
       		   	   ELSE SUBSTRING(ISNULL(MIN(ref_number), ''), 1, 20)
       			  END 
       From referencenumber Where ref_table = 'stops'   
       and ref_tablekey in (select stp_number from stops where stops.ord_hdrnumber = #ords.ord_hdrnumber)  
       and ref_type in  ('BL#','BOL') 
       and ref_sequence = (Select Min(ref_sequence) From referencenumber Where   
           ref_table = 'stops'   
          and ref_tablekey in (select stp_number from stops where stops.ord_hdrnumber =  #ords.ord_hdrnumber
          and ref_type in  ('BL#','BOL') ) )
        ),
		ord_reftype = 'BL#'
		 Where ord_hdrnumber > 0

  
      Update #ords 
       Set ord_refnum =  (  
           --PTS33809 added case was SELECT MIN(ref_number)
           Select oref = CASE
       		   	   WHEN LEN(MIN(ref_number)) <= 20 THEN MIN(ref_number)
       		   	   ELSE SUBSTRING(ISNULL(MIN(ref_number), ''), 1, 20)
       			  END 
           From referencenumber Where ref_table = 'orderheader'   
           and ref_tablekey = #ords.ord_hdrnumber 
           and ref_type in  ('BL#','BOL')  
           and ref_sequence = (Select Min(ref_sequence) From referencenumber Where   
            ref_table = 'orderheader'   
           and ref_tablekey = #ords.ord_hdrnumber and ref_type in ('BL#','BOL'))),
	   ord_reftype = 'BL#'
		 Where IsNull(ord_refnum,'') = ''
         And ord_hdrnumber > 0
        
  
   END  
   

/*    */                
Set ROWCOUNT @Reclimit

If Exists (Select * from #ords) 
	Select -- Distinct
  IsNull(#ords.ord_number,'0' + Replicate(' ',11)) ORDERNO,
  #legs.driver DRIVERCD,
  #legs.tractor TRUCK, 
  #legs.trailer TRAILER, 
  #legs.driver2 DRIVERCD2,
  IsNull(#ords.ord_revtype2,'UNK'+Replicate(' ',3)) TERMINAL,
  IsNull(#ords.ord_shipper,'UNK'+Replicate(' ',5)) SHIPPER,
  IsNull(#ords.invoicenumber,'UNK'+Replicate(' ',9)) INVOICENO,
  IsNUll(#ords.ord_consignee,'UNK'+Replicate(' ',5)) CONSIGNEE, 
  IsNull(#ords.ord_startdate,#legs.startdate)  SHIPDT ,
  IsNull(#ords.ord_startdate,'UNK'+Replicate(' ',7)) PICKUPDT ,
  IsNull(#ords.ord_refnum,'UNK'+Replicate(' ',17)) REFNO,
  IsNull(#ords.ord_reftype,'UNK'+Replicate(' ',9))  REFTYPE,
  IsNull(#ords.ord_invoicestatus,'UNK'+Replicate(' ',3)) INVSTATUS, 
  IsNull(#ords.ord_status,'UNK'+Replicate(' ',3))      STATUS,
  #legs.legpaystatus STATUS,
  ORIGIN_CITY =  Case  IsNull(#ords.origincity,'')
		When '' Then #legs.startcity
		Else #ords.origincity End,
	ORIGIN_STATE = Case IsNull(#ords.originstate,'')
	  When '' Then #legs.startstate
	  Else  #ords.originstate End,
	DESTINATION_CITY =  Case  IsNull(#ords.destcity,'')
		When '' Then #legs.endcity
		Else #ords.destcity End,
	DESTINATION_STATE = Case IsNull(#ords.deststate,'')
	  When '' Then #legs.endstate
	  Else  #ords.deststate End,
	BILLTOCD = Case IsNull(#ords.ord_billto,'')
		When '' Then 'UNK'+Replicate(' ',5) Else #ords.ord_billto End,
 	 CUSTOMER_NAME = Case IsNull(#ords.ord_billto,'')
		When '' Then 'UNK'+Replicate(' ',97) Else #ords.billtoname End,
	REVENUE_TYPE = Case IsNull(#ords.ord_number,'')
		When '' Then 'UNK'+Replicate(' ',3) Else (
      Case @revtype When 'TYPE1' Then IsNull(#ords.ord_revtype1,'UNK'+Replicate(' ',3)) 
      When 'TYPE2' Then IsNull(#ords.ord_revtype2,'UNK'+Replicate(' ',3)) 
	   When 'TYPE3' Then IsNull(#ords.ord_revtype3,'UNK'+Replicate(' ',3)) 
	   When 'TYPE4' Then IsNull(#ords.ord_revtype4,'UNK'+Replicate(' ',3)) 
 	   Else   IsNull(#ords.ord_revtype1,'UNK'+Replicate(' ',3)) 
      End) End,
  #legs.drivertype  DRIVER_TYPE,
  #legs.startcity    LEG_ORIGIN_CITY, 	 
  #legs.startstate LEG_ORIGIN_STATE, 
  #legs.endcity   LEG_DESTINATION_CITY, 
   #legs.endstate LEG_DESTINATION_STATE, 
  #legs.driver  LEG_DRIVER1, 
  #legs.driver2  LEG_DRIVER2, 
 #legs.tractor  LEG_TRUCK,
  #legs.trailer LEG_TRAILER,
  #legs.enddate LEG_DELIVERY_DATE,
  lastleg USERDEFINEDFIELD1,    -- flag Y if last leg 
--  @CHAR20 USERDEFINEDFIELD1,
 -- @CHAR20 USERDEFINEDFIELD2,
  Convert(Char(20),#legs.legpaystatus ) USERDEFINEDFIELD2,
  USERDEFINEDFIELD3 = IsNull((Select edicode From labelfile Where labeldefinition = 'REV'+@revtype and abbr = 
 Case @revtype When 'TYPE1' Then IsNull(#ords.ord_revtype1,'UNK'+Replicate(' ',3)) 
    When 'TYPE2' Then IsNull(#ords.ord_revtype2,'UNK'+Replicate(' ',3)) 
	  When 'TYPE3' Then IsNull(#ords.ord_revtype3,'UNK'+Replicate(' ',3)) 
	  When 'TYPE4' Then IsNull(#ords.ord_revtype4,'UNK'+Replicate(' ',3)) 
 	 Else   IsNull(#ords.ord_revtype1,'UNK'+Replicate(' ',3)) 
   End),''),
 -- @CHAR20 USERDEFINEDFIELD4,
  #legs.trctype USERDEFINEDFIELD4,
  @char20 USERDEFINEDFIELD5,
  @char12 OWEROPERATOR_CODE,
  #legs.mov_number MOVE_NUMBER,
  DRIVERALTID = #legs.driverotherid,
  @CHAR20 USERDEFINEDFIELD7,
  @CHAR20 USERDEFINEDFIELD8,
  @CHAR20 USERDEFINEDFIELD9,
  @CHAR20 USERDEFINEDFIELD10,
  @CHAR20 USERDEFINEDFIELD11,
  @CHAR20 USERDEFINEDFIELD12,
  @CHAR20 USERDEFINEDFIELD13,
  @CHAR20 USERDEFINEDFIELD14,
  @CHAR20 USERDEFINEDFIELD15
  FROM #legs
  LEFT OUTER JOIN #ords
  ON #legs.ord_hdrnumber = #ords.ord_hdrnumber
  --Where #legs.ord_hdrnumber *= #ords.ord_hdrnumber
  Order by legsequence

Else
  Select --Distinct
  '0' + Replicate(' ',11) ORDERNO,
  #legs.driver DRIVERCD,
  #legs.tractor TRUCK, 
  #legs.trailer TRAILER, 
  #legs.driver2 DRIVERCD2,
  'UNK' + Replicate(' ',3) TERMINAL,
  'UNK' + Replicate(' ',5) SHIPPER,
  'UNK' + Replicate(' ',9) INVOICENO,
  'UNK' + Replicate(' ',5) CONSIGNEE, 
  #legs.startdate  SHIPDT ,
  Replicate(' ',10) PICKUPDT ,
	'UNK' + Replicate(' ',18) REFNO,
  'UNK         '  REFTYPE,
  'UNK   ' INVSTATUS, 
  'UNK   '      STATUS,
  ORIGIN_CITY =   #legs.startcity,
	ORIGIN_STATE = #legs.startstate,
	DESTINATION_CITY =   #legs.endcity,
	DESTINATION_STATE =  #legs.endstate,
	BILLTOCD = 'UNK' + Replicate(' ',5) ,
 	 CUSTOMER_NAME =  Replicate(' ',100) ,
	REVENUE_TYPE =  'UNK' + Replicate(' ',3) ,
  #legs.drivertype  DRIVER_TYPE,
  #legs.startcity    LEG_ORIGIN_CITY, 	 
  #legs.startstate LEG_ORIGIN_STATE, 
  #legs.endcity   LEG_DESTINATION_CITY, 
  #legs.endstate LEG_DESTINATION_STATE, 
  #legs.driver  LEG_DRIVER1, 
  #legs.driver2  LEG_DRIVER2, 
 #legs.tractor  LEG_TRUCK,
  #legs.trailer LEG_TRAILER,
  #legs.enddate LEG_DELIVERY_DATE,
  @CHAR20 USERDEFINEDFIELD1,
 --  @CHAR20 USERDEFINEDFIELD2,
  Convert(char(20),'NOPD') USERDEFINEDFIELD2,
  @CHAR20 USERDEFINEDFIELD3,
--  @CHAR20 USERDEFINEDFIELD4,
  USERDEFINEDFIELD4 = #legs.trctype,
  @CHAR20 USERDEFINEDFIELD5,
  @char12 OWEROPERATOR_CODE,
  #legs.mov_number MOVE_NUMBER,
  DRIVERALTID = #legs.driverotherid,
  @CHAR20 USERDEFINEDFIELD7,
  @CHAR20 USERDEFINEDFIELD8,
  @CHAR20 USERDEFINEDFIELD9,
  @CHAR20 USERDEFINEDFIELD10,
  @CHAR20 USERDEFINEDFIELD11,
  @CHAR20 USERDEFINEDFIELD12,
  @CHAR20 USERDEFINEDFIELD13,
  @CHAR20 USERDEFINEDFIELD14,
  @CHAR20 USERDEFINEDFIELD15
  FROM #legs
  LEFT OUTER JOIN #ords
  ON #legs.ord_hdrnumber = #ords.ord_hdrnumber
  --Where #legs.ord_hdrnumber *= #ords.ord_hdrnumber
  Order by legstartdttm

GO
GRANT EXECUTE ON  [dbo].[pegasus_index_sp] TO [public]
GO
