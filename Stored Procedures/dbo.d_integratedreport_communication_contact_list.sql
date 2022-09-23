SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

Create Procedure [dbo].[d_integratedreport_communication_contact_list] (@mov_number int, @lgh_number int, @ord_number varchar (12) , @mpp_id varchar (8), @trc_number varchar (8),  @car_id varchar (8), @cmp_id varchar (8))
AS
/**
 *
 * NAME:
 * dbo.d_integratedreport_communication_contact_list
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure returns contact information for the given order, leg, move or invoice
 *
 * RETURNS:
 * n/a
 *
 * RESULT SETS:
 * 001 - cmp_id
 * 002 - contact_name

 *
 * PARAMETERS:
 * 001 - @type	varchar(20)	- Object type - ORDER, LEG, MOVE and INVOICE are the likely values
 * 002 - @num	int			- Object number for the indicated @type e.g. ord_hdrnumber
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 * vjh - 11/01/200735753 - PTS #35753
 * mtc - 07/12/2010 - PTS #53172 - changed #temp table to @temp table var for performance
 *
 **/

DECLARE @SendCommunicationAssetList as varchar (255), @SendCommunicationUseProfile as varchar (255) --PTS 45046 CGK 2/27/2009
DECLARE @CarrierMgmtSystem as varchar (255)


--CREATE TABLE #temp(
--	[id]			varchar(20) NULL,
--	id_type			varchar (20) NULL,
--	contact_name		varchar (100) NULL,
--	contact_email		varchar (255) NULL,
--	contact_fax		varchar (20) NULL
--)

DECLARE @temp  table ( 
 [id]   varchar(20) NULL,  
 id_type   varchar (20) NULL,  
 contact_name  varchar (100) NULL,  
 contact_email  varchar (255) NULL,  
 contact_fax  varchar (20) NULL  
) 


select @SendCommunicationAssetList = gi_string1 from generalinfo where gi_name = 'SendCommunicationAssetList'
Select @SendCommunicationAssetList = IsNull (@SendCommunicationAssetList, 'CTDA')

select @SendCommunicationUseProfile = gi_string1 from generalinfo where gi_name = 'SendCommunicationUseProfile'
Select @SendCommunicationUseProfile = IsNull (@SendCommunicationUseProfile, 'N')

--PTS 48338 CGK 7/20/2009
select @CarrierMgmtSystem = gi_string1 from generalinfo where gi_name = 'CarrierMgmtSystem'
Select @CarrierMgmtSystem = IsNull (@CarrierMgmtSystem, 'N')

IF ISNull (@ord_number, '') <> ''
Begin
	IF charindex ('C', @SendCommunicationAssetList) > 0 Begin 
		insert @temp (id, id_type, contact_email, contact_name, contact_fax) 
		
			(  
			select stops.cmp_id, 'Company', companyemail.email_address, companyemail.contact_name, companyemail.ce_faxnumber 
			from stops 
			  left join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber
			  left outer join companyemail on stops.cmp_id = companyemail.cmp_id and ce_source = 'CMP' 
			where orderheader.ord_number = @ord_number
			  union
			select ord_company, 'Company', companyemail.email_address, companyemail.contact_name, companyemail.ce_faxnumber 
			from orderheader left outer join companyemail on orderheader.ord_company = companyemail.cmp_id and ce_source = 'CMP' 
			where orderheader.ord_number = @ord_number
			  union
			select ord_billto, 'Company', companyemail.email_address, companyemail.contact_name, companyemail.ce_faxnumber 
			from orderheader left outer join companyemail on orderheader.ord_billto = companyemail.cmp_id and ce_source = 'CMP' 
			where orderheader.ord_number = @ord_number
			  union
			select ord_shipper, 'Company', companyemail.email_address, companyemail.contact_name, companyemail.ce_faxnumber 
			from orderheader left outer join companyemail on orderheader.ord_shipper = companyemail.cmp_id and ce_source = 'CMP' 
			where orderheader.ord_number = @ord_number
			  union	
			select ord_consignee, 'Company', companyemail.email_address, companyemail.contact_name, companyemail.ce_faxnumber 
			from orderheader left outer join companyemail on orderheader.ord_consignee = companyemail.cmp_id and ce_source = 'CMP' 
			where orderheader.ord_number = @ord_number
			)
	End

	IF charindex ('D', @SendCommunicationAssetList) > 0 Begin
		insert @temp (id, id_type, contact_email, contact_name, contact_fax) 
		(  
		select legheader.lgh_driver1, 'Driver', contact_profile.con_email_address1, manpowerprofile.mpp_lastfirst, contact_profile.con_fax_number 
		from stops 
		  left join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber
		  left join legheader on stops.lgh_number = legheader.lgh_number
		  left join manpowerprofile on legheader.lgh_driver1 = manpowerprofile.mpp_id
  		 left outer join contact_profile on  manpowerprofile.mpp_id = contact_profile.con_id and contact_profile.con_asgn_type = 'DRIVER'
		where orderheader.ord_number = @ord_number
		)

		IF @SendCommunicationUseProfile = 'Y' Begin
			insert @temp (id, id_type, contact_email, contact_name, contact_fax) 
				(  
				select legheader.lgh_driver1, 'Driver', manpowerprofile.mpp_email, manpowerprofile.mpp_lastfirst, manpowerprofile.mpp_alternatephone
				from stops 
				  left join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber
				  left join legheader on stops.lgh_number = legheader.lgh_number
				  left join manpowerprofile on legheader.lgh_driver1 = manpowerprofile.mpp_id
  				 where orderheader.ord_number = @ord_number
				  and lgh_driver1 <> 'UNKNOWN'
				)
		End
	End

	IF charindex ('T', @SendCommunicationAssetList) > 0 Begin
		insert @temp (id, id_type, contact_email, contact_name, contact_fax) 
		(  
		select legheader.lgh_tractor, 'Tractor', contact_profile.con_email_address1, tractorprofile.trc_number, contact_profile.con_fax_number 
		from stops 
		  left join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber
		  left join legheader on stops.lgh_number = legheader.lgh_number
		  left join tractorprofile on legheader.lgh_tractor = tractorprofile.trc_number
  		 left outer join contact_profile on  tractorprofile.trc_number = contact_profile.con_id and contact_profile.con_asgn_type = 'TRACTOR'
		where orderheader.ord_number = @ord_number
		)	
		IF @SendCommunicationUseProfile = 'Y' Begin
			insert @temp (id, id_type, contact_email, contact_name, contact_fax) 
			(  
			select legheader.lgh_tractor, 'Tractor', tractorprofile.trc_email, tractorprofile.trc_number, tractorprofile.trc_phone
			from stops 
			  left join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber
			  left join legheader on stops.lgh_number = legheader.lgh_number
			  left join tractorprofile on legheader.lgh_tractor = tractorprofile.trc_number
			where orderheader.ord_number = @ord_number
			and legheader.lgh_tractor <> ' UNKNOWN'
			)	
		End

	End

	IF charindex ('A', @SendCommunicationAssetList) > 0 Begin	
		insert @temp (id, id_type, contact_email, contact_name, contact_fax) 
		(  
		select legheader.lgh_carrier, 'Carrier', contact_profile.con_email_address1, carrier.car_name, contact_profile.con_fax_number 
		from stops 
		  left join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber
		  left join legheader on stops.lgh_number = legheader.lgh_number
		  left join carrier on legheader.lgh_carrier = carrier.car_id
  		 left outer join contact_profile on  carrier.car_id = contact_profile.con_id and contact_profile.con_asgn_type = 'CARRIER'
		where orderheader.ord_number = @ord_number
		)

		IF @CarrierMgmtSystem = 'Y' Begin --PTS 48338 CGK 7/20/2009
			insert @temp (id, id_type, contact_email, contact_name, contact_fax) 
				(  
				select	carriercontacts.car_id, 
						'Carrier', 
						carriercontacts.cc_email, 
						'cname' =	CASE 
										WHEN IsNull(carriercontacts.cc_lname, '') = '' THEN carriercontacts.cc_fname 
										WHEN IsNull(carriercontacts.cc_fname, '') = '' THEN carriercontacts.cc_lname 
										ELSE carriercontacts.cc_fname + ' ' + carriercontacts.cc_lname
									END,				
						carriercontacts.cc_fax 
				from stops 
				  left join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber
				  left join legheader on stops.lgh_number = legheader.lgh_number
				  left join carrier on legheader.lgh_carrier = carrier.car_id
  				 left outer join carriercontacts on  carrier.car_id = carriercontacts.car_id 
				where orderheader.ord_number = @ord_number
				)
		End --END PTS 48338 CGK 7/20/2009	

		IF @SendCommunicationUseProfile = 'Y' Begin
			insert @temp (id, id_type, contact_email, contact_name, contact_fax) 
			(  
			select legheader.lgh_carrier, 'Carrier', carrier.car_email, carrier.car_name, carrier.car_phone3 
			from stops 
			  left join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber
			  left join legheader on stops.lgh_number = legheader.lgh_number
			  left join carrier on legheader.lgh_carrier = carrier.car_id
			where orderheader.ord_number = @ord_number
			and legheader.lgh_carrier <> 'UNKNOWN'
			)
		End

	End

End


IF ISNull (@mov_number, 0) > 0
Begin
	IF charindex ('C', @SendCommunicationAssetList) > 0 Begin	
		insert @temp (id, id_type, contact_email, contact_name, contact_fax) 
		(  
		select stops.cmp_id, 'Company', companyemail.email_address, companyemail.contact_name, companyemail.ce_faxnumber 
		from stops 
		  left outer join companyemail on stops.cmp_id = companyemail.cmp_id and ce_source = 'CMP' 
		where stops.mov_number = @mov_number )
	End

	IF charindex ('D', @SendCommunicationAssetList) > 0 Begin	
		insert @temp (id, id_type, contact_email, contact_name, contact_fax) 
		(  
		select legheader.lgh_driver1, 'Driver', contact_profile.con_email_address1, manpowerprofile.mpp_lastfirst, contact_profile.con_fax_number 
		from stops 
		  left join legheader on stops.lgh_number = legheader.lgh_number
		  left join manpowerprofile on legheader.lgh_driver1 = manpowerprofile.mpp_id
  		 left outer join contact_profile on  manpowerprofile.mpp_id = contact_profile.con_id and contact_profile.con_asgn_type = 'DRIVER'
		where stops.mov_number = @mov_number
		)

		IF @SendCommunicationUseProfile = 'Y' Begin
			insert @temp (id, id_type, contact_email, contact_name, contact_fax) 
				(  
				select legheader.lgh_driver1, 'Driver', manpowerprofile.mpp_email, manpowerprofile.mpp_lastfirst, manpowerprofile.mpp_alternatephone 
				from stops 
				  left join legheader on stops.lgh_number = legheader.lgh_number
				  left join manpowerprofile on legheader.lgh_driver1 = manpowerprofile.mpp_id
				where stops.mov_number = @mov_number
				AND lgh_driver1 <> 'UNKNOWN'
				)
		End


	End
	
	IF charindex ('T', @SendCommunicationAssetList) > 0 Begin	
		insert @temp (id, id_type, contact_email, contact_name, contact_fax) 
		(  
		select legheader.lgh_tractor, 'Tractor', contact_profile.con_email_address1, tractorprofile.trc_number, contact_profile.con_fax_number 
		from stops 
		  left join legheader on stops.lgh_number = legheader.lgh_number
		  left join tractorprofile on legheader.lgh_tractor = tractorprofile.trc_number
  		 left outer join contact_profile on  tractorprofile.trc_number = contact_profile.con_id and contact_profile.con_asgn_type = 'TRACTOR'
		where stops.mov_number = @mov_number
		)	

		IF @SendCommunicationUseProfile = 'Y' Begin
			insert @temp (id, id_type, contact_email, contact_name, contact_fax) 
			(  
			select legheader.lgh_tractor, 'Tractor', tractorprofile.trc_email, tractorprofile.trc_number, tractorprofile.trc_phone
			from stops 
			  left join legheader on stops.lgh_number = legheader.lgh_number
			  left join tractorprofile on legheader.lgh_tractor = tractorprofile.trc_number
  			 where stops.mov_number = @mov_number
			 and legheader.lgh_tractor <> 'UNKNOWN'
			)	
		End
	End

	IF charindex ('A', @SendCommunicationAssetList) > 0 Begin	
		insert @temp (id, id_type, contact_email, contact_name, contact_fax) 
		(  
		select legheader.lgh_carrier, 'Carrier', contact_profile.con_email_address1, carrier.car_name, contact_profile.con_fax_number 
		from stops 
		  left join legheader on stops.lgh_number = legheader.lgh_number
		  left join carrier on legheader.lgh_carrier = carrier.car_id
  		 left outer join contact_profile on  carrier.car_id = contact_profile.con_id and contact_profile.con_asgn_type = 'CARRIER'
		where stops.mov_number = @mov_number
		)

		IF @CarrierMgmtSystem = 'Y' Begin --PTS 48338 CGK 7/20/2009
			insert @temp (id, id_type, contact_email, contact_name, contact_fax) 
				(  
				select	carriercontacts.car_id, 
						'Carrier', 
						carriercontacts.cc_email, 
						'cname' =	CASE 
										WHEN IsNull(carriercontacts.cc_lname, '') = '' THEN carriercontacts.cc_fname 
										WHEN IsNull(carriercontacts.cc_fname, '') = '' THEN carriercontacts.cc_lname 
										ELSE carriercontacts.cc_fname + ' ' + carriercontacts.cc_lname
									END,				
						carriercontacts.cc_fax 
				from stops 
					left join legheader on stops.lgh_number = legheader.lgh_number
					left join carrier on legheader.lgh_carrier = carrier.car_id
  					left outer join carriercontacts on  carrier.car_id = carriercontacts.car_id 
				where stops.mov_number = @mov_number
  				
				)
		End --END PTS 48338 CGK 7/20/2009	

		IF @SendCommunicationUseProfile = 'Y' Begin

			insert @temp (id, id_type, contact_email, contact_name, contact_fax) 
			(  
			select legheader.lgh_carrier, 'Carrier', carrier.car_email, carrier.car_name, carrier.car_phone3 
			from stops 
			  left join legheader on stops.lgh_number = legheader.lgh_number
			  left join carrier on legheader.lgh_carrier = carrier.car_id
  			 			where stops.mov_number = @mov_number
			and legheader.lgh_carrier <> 'UNKNOWN' 
			)
		End

	End
End
Else IF ISNull (@lgh_number, 0) > 0
Begin

	IF charindex ('C', @SendCommunicationAssetList) > 0 Begin	
		insert @temp (id, id_type, contact_email, contact_name, contact_fax) 
		(  
		select stops.cmp_id, 'Company', companyemail.email_address, companyemail.contact_name, companyemail.ce_faxnumber 
		from stops 
		  left outer join companyemail on stops.cmp_id = companyemail.cmp_id and ce_source = 'CMP' 
		where stops.lgh_number = @lgh_number )
	End

	IF charindex ('D', @SendCommunicationAssetList) > 0 Begin	
		insert @temp (id, id_type, contact_email, contact_name, contact_fax) 
		(  
		select legheader.lgh_driver1, 'Driver', contact_profile.con_email_address1, manpowerprofile.mpp_lastfirst, contact_profile.con_fax_number 
		from legheader
		  left join manpowerprofile on legheader.lgh_driver1 = manpowerprofile.mpp_id
  		 left outer join contact_profile on  manpowerprofile.mpp_id = contact_profile.con_id and contact_profile.con_asgn_type = 'DRIVER'
		where legheader.lgh_number = @lgh_number
		)

		IF @SendCommunicationUseProfile = 'Y' Begin

			insert @temp (id, id_type, contact_email, contact_name, contact_fax) 
			(  
			select legheader.lgh_driver1, 'Driver', manpowerprofile.mpp_email, manpowerprofile.mpp_lastfirst, manpowerprofile.mpp_alternatephone 
			from legheader
			  left join manpowerprofile on legheader.lgh_driver1 = manpowerprofile.mpp_id
			where legheader.lgh_number = @lgh_number
			AND lgh_driver1 <> 'UNKNOWN'
			)
		End
	End

	IF charindex ('T', @SendCommunicationAssetList) > 0 Begin	
		insert @temp (id, id_type, contact_email, contact_name, contact_fax) 
		(  
		select legheader.lgh_tractor, 'Tractor', contact_profile.con_email_address1, tractorprofile.trc_number, contact_profile.con_fax_number 
		from legheader
		  left join tractorprofile on legheader.lgh_tractor = tractorprofile.trc_number
  		 left outer join contact_profile on  tractorprofile.trc_number = contact_profile.con_id and contact_profile.con_asgn_type = 'TRACTOR'
		where legheader.lgh_number = @lgh_number
		)

		IF @SendCommunicationUseProfile = 'Y' Begin
			insert @temp (id, id_type, contact_email, contact_name, contact_fax) 
			(  
			select legheader.lgh_tractor, 'Tractor', tractorprofile.trc_email, tractorprofile.trc_number, tractorprofile.trc_phone
			from legheader
			  left join tractorprofile on legheader.lgh_tractor = tractorprofile.trc_number
  			 where legheader.lgh_number = @lgh_number
			and legheader.lgh_number  <> 'UNKNOWN'
			)
		End


	End	

	IF charindex ('A', @SendCommunicationAssetList) > 0 Begin	
		insert @temp (id, id_type, contact_email, contact_name, contact_fax) 
		(  
		select legheader.lgh_carrier, 'Carrier', contact_profile.con_email_address1, carrier.car_name, contact_profile.con_fax_number 
		from legheader
		  left join carrier on legheader.lgh_carrier = carrier.car_id
  		 left outer join contact_profile on  carrier.car_id = contact_profile.con_id and contact_profile.con_asgn_type = 'CARRIER'
		where legheader.lgh_number = @lgh_number
		)

		IF @CarrierMgmtSystem = 'Y' Begin --PTS 48338 CGK 7/20/2009
			insert @temp (id, id_type, contact_email, contact_name, contact_fax) 
				(  
				select	carriercontacts.car_id, 
						'Carrier', 
						carriercontacts.cc_email, 
						'cname' =	CASE 
										WHEN IsNull(carriercontacts.cc_lname, '') = '' THEN carriercontacts.cc_fname 
										WHEN IsNull(carriercontacts.cc_fname, '') = '' THEN carriercontacts.cc_lname 
										ELSE carriercontacts.cc_fname + ' ' + carriercontacts.cc_lname
									END,				
						carriercontacts.cc_fax 
				from legheader
					left join carrier on legheader.lgh_carrier = carrier.car_id
  				  	left outer join carriercontacts on  carrier.car_id = carriercontacts.car_id 
				where legheader.lgh_number = @lgh_number
				)
		End --END PTS 48338 CGK 7/20/2009	


		IF @SendCommunicationUseProfile = 'Y' Begin
			insert @temp (id, id_type, contact_email, contact_name, contact_fax) 
				(  
				select legheader.lgh_carrier, 'Carrier', carrier.car_email, carrier.car_name, carrier.car_phone3 
				from legheader
				  left join carrier on legheader.lgh_carrier = carrier.car_id
				where legheader.lgh_number = @lgh_number
				AND legheader.lgh_number <> 'UNKNOWN'
				)
		End

	End

End


IF @mpp_id IS NOT NULL AND @mpp_id <> '' AND @mpp_id <> 'UNKNOWN'
Begin
	IF charindex ('D', @SendCommunicationAssetList) > 0 Begin	
		insert @temp (id, id_type, contact_email, contact_name, contact_fax) 
			(  
			select @mpp_id, 'Driver', contact_profile.con_email_address1, manpowerprofile.mpp_lastfirst, contact_profile.con_fax_number 
			from manpowerprofile
			left outer join contact_profile on  manpowerprofile.mpp_id = contact_profile.con_id and contact_profile.con_asgn_type = 'DRIVER'
			where  contact_profile.con_id = @mpp_id
			)

		IF @SendCommunicationUseProfile = 'Y' AND @mpp_id <> 'UNKNOWN' Begin

			insert @temp (id, id_type, contact_email, contact_name, contact_fax) 
			(  
			select @mpp_id, 'Driver', manpowerprofile.mpp_email, manpowerprofile.mpp_lastfirst, manpowerprofile.mpp_alternatephone 
			from manpowerprofile
			where  manpowerprofile.mpp_id = @mpp_id
			)

		End


	End
End

IF @trc_number IS NOT NULL AND @trc_number <> '' AND @trc_number <> 'UNKNOWN'
Begin
	IF charindex ('T', @SendCommunicationAssetList) > 0 Begin	
		insert @temp (id, id_type, contact_email, contact_name, contact_fax) 
			(  
			select @trc_number, 'Tractor', contact_profile.con_email_address1, tractorprofile.trc_number, contact_profile.con_fax_number 
			from tractorprofile
			  left outer join contact_profile on contact_profile.con_id = tractorprofile.trc_number and contact_profile.con_asgn_type = 'TRACTOR'
			where contact_profile.con_id = @trc_number
			)
		IF @SendCommunicationUseProfile = 'Y' AND @trc_number <> 'UNKNOWN' Begin
			insert @temp (id, id_type, contact_email, contact_name, contact_fax) 
			(  
			select @trc_number, 'Tractor', tractorprofile.trc_email, tractorprofile.trc_number, tractorprofile.trc_phone
			from tractorprofile
			where tractorprofile.trc_number = @trc_number
			)
		End
	End
End

IF @car_id IS NOT NULL AND @car_id <> '' AND @car_id <> 'UNKNOWN'
Begin	
	IF charindex ('A', @SendCommunicationAssetList) > 0 Begin	
		insert @temp (id, id_type, contact_email, contact_name, contact_fax) 
			(  
			select @car_id, 'Carrier', contact_profile.con_email_address1, carrier.car_name, contact_profile.con_fax_number 
			from carrier
			  left outer join contact_profile on carrier.car_id = contact_profile.con_id AND contact_profile.con_asgn_type = 'CARRIER'
			where carrier.car_id = @car_id
			)

		IF @CarrierMgmtSystem = 'Y' Begin --PTS 48338 CGK 7/20/2009
			insert @temp (id, id_type, contact_email, contact_name, contact_fax) 
				(  
				select	carriercontacts.car_id, 
						'Carrier', 
						carriercontacts.cc_email, 
						'cname' =	CASE 
										WHEN IsNull(carriercontacts.cc_lname, '') = '' THEN carriercontacts.cc_fname 
										WHEN IsNull(carriercontacts.cc_fname, '') = '' THEN carriercontacts.cc_lname 
										ELSE carriercontacts.cc_fname + ' ' + carriercontacts.cc_lname
									END,				
						carriercontacts.cc_fax 
				from carrier
  				  	left outer join carriercontacts on  carrier.car_id = carriercontacts.car_id 
				where carrier.car_id = @car_id
				)
		End --END PTS 48338 CGK 7/20/2009	



		IF @SendCommunicationUseProfile = 'Y' AND @car_id <> 'UNKNOWN' Begin
			insert @temp (id, id_type, contact_email, contact_name, contact_fax) 
				(  
				select @car_id, 'Carrier', carrier.car_email, carrier.car_name, carrier.car_phone3 
				from carrier
				where carrier.car_id = @car_id
				)
		End
	End
End

IF @cmp_id IS NOT NULL AND @cmp_id <> '' AND @cmp_id <> 'UNKNOWN'
Begin
	IF charindex ('C', @SendCommunicationAssetList) > 0 Begin	
		insert @temp (id, id_type, contact_email, contact_name, contact_fax) 
			(  select company.cmp_id, 'Company', companyemail.email_address, companyemail.contact_name, companyemail.ce_faxnumber 
			from company left outer join companyemail on company.cmp_id = companyemail.cmp_id and ce_source = 'CMP' 
			where company.cmp_id = @cmp_id
			)
	End
End

select distinct id, id_type, contact_name, contact_email, contact_fax, 'N' as send_email, 'N' as send_fax
from @temp
where (id <> 'UNKNOWN')

GO
GRANT EXECUTE ON  [dbo].[d_integratedreport_communication_contact_list] TO [public]
GO
