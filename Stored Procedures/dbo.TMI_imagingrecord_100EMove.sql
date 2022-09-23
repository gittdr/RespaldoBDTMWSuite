SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

/*
Created for TMI on PTS 17833
Example call 
exec TMI_imagingrecord_100EMove @movnumber =67340

These records are to be created when the Empty Move starts an every time any of the info on the record changes.
If the event has not been completed, don't provide the date.


****** REMEMBER RETURNS NOTHING IF Move HAS NO ASSETS **********
DPETE 17833 4/17/03 Per request of TMI, set bill to to EMPTY for empty moves.
DPETE 24142 7/30/04 remove tractor <> UNKNOWN from where clause

*/
Create Procedure [dbo].[TMI_imagingrecord_100EMove] @movnumber int
As

--ILB 01/10/03 PTS# 15477
--DTS when sql returns messages due to inserts
SET NOCOUNT ON
--ILB 01/10/03

Declare @scac varchar(10),@trctype varchar(12),@trctype2 varchar(12),@trltype varchar(12),@emptydate datetime,@terminalrevtype varchar(6),@ltlflag char(1),@logisticsload char(1)
Declare @revstart int,@ordrevtype varchar(10),@revtype varchar(10)
Declare @firststop int, @laststop int
Declare @Oname varchar(50),@Ocity varchar(50),@ostate varchar(2),@ozip varchar(15)
Declare @Dname varchar(50),@Dcity varchar(50),@Dstate varchar(2),@Dzip varchar(15)

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
/*
   SELECT @ordrevtype = 
     Case @revtype
       When 'REVTYPE1' Then ord_revtype1
       When 'REVTYPE2' Then ord_revtype2
       When 'REVTYPE3' Then ord_revtype3
       When 'REVTYPE4' Then ord_revtype4
       Else ord_revtype1
     End
   FROM orderheader where ord_hdrnumber = @ordhdrnumber
*/
  
   SELECT @SCAC = isnull(UPPER(edicode),abbr)
   FROM labelfile
   WHERE labeldefinition = @revtype
   AND    abbr = 'UNK'  -- no order so use the UNK revtype

   -- handle spaces in edicode field
   IF LEN(RTRIM(@SCAC)) = 0 
       SELECT @SCAC = '????' 

   SELECT @SCAC = SUBSTRING(@SCAC,1,4) + Replicate(' ',4 - Datalength(SUBSTRING(@SCAC,1,4)))

END
-- If trip is complete, set the trailer empty call date (ecalldate) to end date on leg.
If Exists (Select lgh_outstatus from legheader where mov_number = @movnumber and lgh_outstatus = 'CMP'
  and lgh_startdate = (Select Max(lgh_startdate) from legheader l2 where l2.mov_number = @movnumber ) )
	Select @emptydate = lgh_enddate From legheader where mov_number = @movnumber
   and lgh_startdate = (Select Max(lgh_startdate) from legheader l2 where l2.mov_number = @movnumber )

Else
	Select @emptydate = '1-1-1950'


Select @firststop = stp_number from stops
Where mov_number = @movnumber and stp_mfh_sequence = 1

Select @oname = IsNull(Substring(company.cmp_name,1,50),''),
   @ocity = IsNull(Substring(cty_name,1,50),''), @ostate = IsNull(Substring(cty_state,1,2),''),
   @ozip = IsNull(IsNull(company.cmp_zip,city.cty_zip),'')
From stops , city ,company where stp_number = @firststop and city.cty_code =* stp_city and company.cmp_id =* stops.cmp_id

Select @laststop = stp_number from stops 
Where  mov_number = @movnumber and stp_mfh_sequence = (Select Max(stp_mfh_sequence) From stops s2
  Where s2.mov_number = @movnumber)


Select @dname = IsNull(Substring(company.cmp_name,1,50),''),
   @dcity = IsNull(Substring(cty_name,1,50),''), @dstate = IsNull(Substring(cty_state,1,2),''),
   @Dzip = IsNull(IsNull(company.cmp_zip,city.cty_zip),'')
From stops , city ,company where stp_number = @laststop and city.cty_code =* stp_city and company.cmp_id =* stops.cmp_id



Select '10002' 
+ Substring(@scac,1,4) 
+ Replicate(' ',10) 
+ Convert(Char(15),@movnumber)
+ '0' + replicate (' ',19)  -- no order number on empty move
+ Convert( varchar(12),s.lgh_number) 
+ replicate(' ',12 - datalength(Convert( varchar(12),s.lgh_number)))
+ convert(char(10),IsNull(evt_tractor,' ')) 
+ convert(char(10),IsNull(evt_driver1,' ')) 
+ Case IsNull(evt_driver2,'UNKNOWN')When 'UNKNOWN' Then replicate(' ',10) Else convert(char(10),evt_driver2) End 
+ convert(char(25),IsNull(evt_trailer1,' ')) 
+ Case IsNull(evt_trailer2,'UNKNOWN') When 'UNKNOWN' Then Replicate (' ',25) Else convert(char(25),evt_trailer2) End 
+ Convert(char(6),Case @trltype When 'TYPE2' Then isnull(t.trl_type2, @char6) When 'TYPE3' Then isnull(t.trl_type3, @char6) When 'TYPE4' Then isnull(t.trl_type4, @char6) Else isnull(t.trl_type1, @char6) End) 
+ Convert( char(10),lgh_startdate,101)+' '+Convert( char(8),lgh_startdate,108)
+ Convert( char(10),lgh_startdate,101)+' '+Convert( char(8),lgh_startdate,108)
+ replicate (' ',19)   -- tcalldate not required
+ Case lgh_outstatus When 'CMP' Then Convert( char(10),lgh_enddate,101)+' '+Convert( char(8),lgh_enddate,108) Else replicate(' ',19) End
+ Case @emptydate When '1-1-1950' then replicate(' ',19) Else Convert( char(10),@emptydate,101)+' '+Convert( char(8),@emptydate,108) End 
+ Replicate(' ',15)  -- no invoice
+ 'EMPTY'+Replicate(' ',5)  -- no bill to (set 'empty'per email chris ryan 4/16/03) 
+ replicate(' ',10)  -- bill rep
+ Replicate(' ',50)
+ Replicate(' ',40) 
+ Replicate(' ',40)
+ Replicate(' ',50)
+ Replicate(' ',25)
+ Replicate(' ',15)
+ Convert(char(50),Substring(Isnull(@oname,' '),1,50)) 
+ Convert(char(50),@ocity)
+ Convert(char(25),@ostate)
+ Convert(char(15),@ozip)
+ Convert(char(50),Substring(Isnull(@dname,' '),1,50)) 
+ Convert(char(50),@dcity)
+ Convert(char(25),@dstate)
+ Convert(char(15),@dzip)
+ 'N'    -- LTLFLAG
+ Convert(char(6),Case @trctype  When 'TYPE1' Then IsNull(tc.trc_type1,' ') When 'TYPE2' Then IsNull(tc.trc_type2,' ') When 'TYPE3' Then IsNull(tc.trc_type3,' ') When 'TYPE4' Then IsNull(tc.trc_type4,' ') Else IsNull(tc.trc_type1,' ') End) 
+ Case @trctype2 When 'TYPE1' Then Substring(IsNull(tc.trc_type1,' '),1,1)  When 'TYPE2' Then Substring(IsNull(tc.trc_type2,' '),1,1)  When 'TYPE3' Then Substring(IsNull(tc.trc_type3,' '),1,1)  When 'TYPE4' Then Substring(IsNull(tc.trc_type4,' '),1,1) Else 'M' End
+ replicate(' ',10)   -- agent
+ Convert(char(6),lgh_type1)    -- terminal
+  'N'   -- Logistics load don't know how to determine
+ replicate(' ',10)  -- misc equipment
+ Convert(char(1),Case IsNull(tc.trc_owner,'UNKNOWN') When 'UNKNOWN' Then 'C' Else 'D' End) 
+ Convert(char(1),Case IsNull(t.trl_owner,'UNKNOWN') When 'UNKNOWN' Then 'C' Else 'D' End) 
+ replicate(' ',1)  -- misc eqpt own  */
From   stops s ,event e , legheader, 
trailerprofile t, tractorprofile tc

Where s.stp_number = @firststop
    And e.stp_number = s.stp_number
	 And e.evt_sequence = 1
	And legheader.lgh_number = s.lgh_number
    And tc.trc_number = e.evt_tractor
    And t.trl_number = e.evt_trailer1
    And (evt_tractor <> 'UNKNOWN' and evt_driver1 <> 'UNKNOWN' )


GO
GRANT EXECUTE ON  [dbo].[TMI_imagingrecord_100EMove] TO [public]
GO
