SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

Create Proc [dbo].[getSafetyInfoforForTrip] @ord varchar(12), @lgh int,@mov int
As
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
	SR 17782 DPETE created 11/20/03
	   2/6/4 use leg header first if passed, since we allow leg selection on multileg trip
 * 11/30/2007.01 - PTS40464 - JGUO - convert old style outer join syntax to ansi outer join syntax.
 *
 **/
Declare @cmdcode varchar(8),@cmdname varchar(50),@shipper varchar(8),@ordnbr int,@shippername varchar(100),@hazmat tinyint
Select @shipper = 'UNKNOWN'
/* use leg if passed  */
If @lgh > 0 
 BEGIN ---------------------------
   If Rtrim(@ord) = ''
    BEGIN      --*****************
     Select @ordnbr = ord_hdrnumber From stops Where lgh_number = @lgh and ord_hdrnumber > 0 and stp_sequence = 
        (Select Min(stp_sequence) from stops s2 Where s2.lgh_number = @lgh and ord_hdrnumber > 0)
   
     If @ordNbr > 0 
        Select @cmdcode = orderheader.cmd_code,@shipper = ord_shipper From orderheader Where ord_hdrnumber = @ordnbr

     Else -- no order on leg
       BEGIN           --===================
       	Select @cmdcode = 'UNKNOWN'
        Select @shipper = 'UNKNOWN'
       END             --===================
    END       --********************
   Else
    Select @cmdcode = orderheader.cmd_code,@shipper = ord_shipper From orderheader Where ord_number = @ord
 END --------------------------
Else  /* find the leg_number */
 BEGIN   --.................................
  If Rtrim(@ord) > ''

    Select @lgh = lgh_number,@cmdcode = orderheader.cmd_code,@shipper = ord_shipper From orderheader,stops 
    Where orderheader.ord_number = @ord and stops.ord_hdrnumber = orderheader.ord_hdrnumber
    And stp_sequence = 1

  Else 
    BEGIN   --#####################
   
     If @mov > 0 and IsNull(@lgh,0) = 0
       BEGIN        --!!!!!!!!!!!!!!!!!!!!!!!!!!!
        -- try for first order on move
        Select @lgh = lgh_number,@ordnbr = ord_hdrnumber From stops Where mov_number = @mov
        And stp_mfh_sequence = (Select min(stp_mfh_sequence) From stops s2 Where s2.mov_number = @mov
        And ord_hdrnumber > 0)

        If @ordNbr > 0 
           Select @cmdcode = orderheader.cmd_code,@shipper = ord_shipper From orderheader Where ord_hdrnumber = @ordnbr

        Else -- no order on move
          BEGIN          ----------------
            Select @lgh = lgh_number From Stops
            Where mov_number = @mov and stp_mfh_sequence = (Select min(stp_mfh_sequence) From stops s2 Where s2.mov_number = @mov)
       
            Select @cmdcode = 'UNKNOWN'
            Select @shipper = 'UNKNWON'
          END            ------------------- 
        END        --!!!!!!!!!!!!!!!!!!!!!!!
    END    --#####################
 END   --....................................

Select @cmdName = cmd_Name,@Hazmat = cmd_Hazardous From Commodity Where cmd_code = @cmdcode
Select @shippername = cmp_name from company Where cmp_id = @shipper

Select evt_Driver1,
  evt_driver2,
  evt_tractor,
  evt_Trailer1,
  evt_trailer2,
  ord_Shipper = IsNull(@Shipper,'UNKNOWN'),
  cmd_code = IsNull(@cmdcode,'UNKNOWN'),
  cmd_name = IsNull(@cmdname,'UNKNOWN'),
  shippername = IsNull(@shippername,''),
  drv1name = IsNUll(m1.mpp_firstname+' ','')+IsNull(m1.mpp_Middlename+' ','')+IsNull(m1.mpp_lastname,''),
  drv1address1 = IsNull(m1.mpp_address1,''),
  drv1address2 = IsNull(m1.mpp_address2,''),
  drv1city = IsNull(m1.mpp_city,0),
  drv1state = IsNull(m1.mpp_state,''),
  drv1zip = IsNull(m1.mpp_zip,''),
  drv1ssn = IsNull(m1.mpp_ssn,''),
  drv1licensenbr = IsNull(m1.mpp_Licensenumber,''),
  drv1licensestate = IsNull(m1.mpp_licensestate,''),
  drv1licenseclass = IsNull(m1.mpp_licenseclass,'UNK'),
  drv1homephone = IsNull(m1.mpp_homephone,''),
  drv1dateofbirth = m1.mpp_dateofbirth,
  drv1hiredate = m1.mpp_hiredate,
  drv1terminal = IsNull(m1.mpp_terminal,'UNK'),
  drv1NbrDependents = IsNull(m1.mpp_NbrDependents,0),
  drv1EmerName = IsNUll(m1.mpp_emerName,''),
  drv1EmerPhone = IsNull(m1.mpp_emerPhone,''),
  drv2name = IsNUll(m2.mpp_firstname+' ','')+IsNull(m2.mpp_Middlename+' ','')+IsNull(m2.mpp_lastname,''),
  drv2address1 = IsNull(m2.mpp_address1,''),
  drv2address2 = IsNull(m2.mpp_address2,''),
  drv2city = IsNull(m2.mpp_city,0),
  drv2state = IsNull(m2.mpp_state,''),
  drv2zip = IsNull(m2.mpp_zip,''),
  drv2ssn = IsNull(m2.mpp_ssn,''),
  drv2licensenbr = IsNull(m2.mpp_Licensenumber,''),
  drv2licensestate = IsNull(m2.mpp_licensestate,''),
  drv2licenseclass = IsNull(m2.mpp_licenseclass,'UNK'),
  drv2homephone = IsNUll(m2.mpp_homephone,''),
  drv2dateofbirth = m2.mpp_dateofbirth,
  drv2hiredate = m2.mpp_hiredate,
  drv2terminal = IsNull(m2.mpp_terminal,'UNK'),
  drv2NbrDependents = IsNull(m2.mpp_NbrDependents,0),
  drv2EmerName = IsNUll(m2.mpp_emerName,''),
  drv2EmerPhone = IsNull(m2.mpp_emerPhone,''),
  trcserial = IsNull(trc_serial,''),
  trcyear = IsNull(trc_year,''),
  trcmake = IsNull(trc_make,''),
  trcmodel = IsNull(trc_model,''),
  trcOwner= Case IsNull(trc_owner,'UNKNOWN') When 'UNKNOWN' Then '' Else trc_Owner End,
  trcownername = IsNull((Select IsNull(pto_Fname+' ','')+IsNull(pto_lname,'')+'~r'
      +IsNull(pto_address1+'~r','')+IsNull(cty_name+', ','')+Isnull(cty_state+'~r','')+
      IsNull(pto_phone1,'')
      From city RIGHT OUTER JOIN payto ON city.cty_code = payto.pto_city Where pto_ID = trc_owner and trc_owner <> 'UNKNOWN'),''),
  trl1serial = IsNull(trl1.trl_serial,''),
  trl1make = IsNull(trl1.trl_make,''),
  trl1model = IsNull(trl1.trl_model,''),
  trl1owner = Case IsNull(trl1.trl_owner,'UNKNOWN') When 'UNKNOWN' Then '' Else trl1.trl_owner End,
  trl1Ownername = (Select IsNull(pto_Fname+' ','')+IsNull(pto_lname,'')+'~r'
      +IsNull(pto_address1+'~r','')+IsNull(cty_name+', ','')+Isnull(cty_state+'~r','')+
      IsNull(pto_phone1,'')
      From city RIGHT OUTER JOIN payto ON city.cty_code = pto_city Where pto_ID = trl1.trl_owner and trl1.trl_Owner <> 'UNKNOWN'), 
  trl2serial = IsNull(trl2.trl_serial,''),
  trl2make = IsNull(trl2.trl_make,''),
  trl2model = IsNull(trl2.trl_model,''),
  trl2owner =  Case IsNull(trl2.trl_owner,'UNKNOWN') When 'UNKNOWN' Then '' Else trl2.trl_owner End,
  trl2Ownername = (Select IsNull(pto_Fname+' ','')+IsNull(pto_lname,'')+'~r'
      +IsNull(pto_address1+'~r','')+IsNull(cty_name+', ','')+Isnull(cty_state+'~r','')+
      IsNull(pto_phone1,'')
      From city RIGHT OUTER JOIN  payto ON city.cty_code = payto.pto_city Where pto_ID = trl2.trl_owner and trl2.trl_Owner <> 'UNKNOWN'), 
  trcLicense = IsNull(trc_licnum,''),
  trcLicenseState = IsNull(trc_licstate,''),
  trl1license = IsNull(trl1.trl_licnum,''),
  trl1licensestate = IsNull(trl1.trl_Licstate,''),
  trl2license = IsNull(trl2.trl_licnum,''),
  trl2licensestate = IsNull(trl2.trl_Licstate,''),
  trl1year = IsNull(trl1.trl_year,''),
  trl2year = IsNull(trl2.trl_year,''),
  drv1ctynmstct = (Select cty_nmstct From city Where cty_code = m1.mpp_city),
  drv2ctynmstct =(Select cty_nmstct From city Where cty_code = m2.mpp_city),
  evt_carrier = IsNull(evt_carrier,'UNKNOWN'),
  carriername =  IsNull(car_name,''),
  carrieraddress1 = IsNull(car_address1,''),
  carrieraddress2 = IsNull(car_address2,''),
  carriercitystate = Case car.cty_code When 0 Then '' Else IsNull(cty_name,'')+IsNull(', '+cty_state,'')+'   '+IsNull(car_zip,'') End,
  cmd_Hazardous = IsNull(@hazmat,0)
  From stops,event,manpowerprofile m1,manpowerprofile m2,
  tractorprofile, trailerprofile trl1, trailerprofile trl2, carrier car,city c1
  
  where stops.lgh_number = @lgh
  and stops.stp_number = (Select min(stp_number) From stops s2 Where s2.lgh_number = @lgh)
  and event.stp_number = stops.stp_number
  and evt_sequence = 1
  and m1.mpp_id = evt_driver1
  and m2.mpp_id = evt_driver2
  and tractorprofile.trc_number = evt_tractor
  and trl1.trl_id = evt_Trailer1
  and trl2.trl_id = evt_Trailer2
  and car.car_id = evt_carrier
  and c1.cty_code = car.cty_code
  
  
    

GO
GRANT EXECUTE ON  [dbo].[getSafetyInfoforForTrip] TO [public]
GO
