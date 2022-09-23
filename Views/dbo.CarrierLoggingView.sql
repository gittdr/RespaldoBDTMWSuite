SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[CarrierLoggingView]
as


select 
	crr_newcarrier as 'CarId',
	'Removed Reason' as 'Type',
	crr_id as 'ID',
	lgh_number as 'LegNumber',
	'Prev Car' + ': ' + crr_prevcarrier + ' | ' + 'New Car' + ': ' + crr_newcarrier as 'Info',
	crr_reason as 'Reason',
	crr_note as 'Note',
	crr_user as 'User',
	crr_lastupdated as 'Last Updated'
from carrierremovedreason
	
union

select 
	crr_prevcarrier as 'CarId',
	'Removed Reason' as 'Type',
	crr_id as 'ID',
	lgh_number as 'LegNumber',
	'Prev Car' + ': ' + crr_prevcarrier + ' | ' + 'New Car' + ': ' + crr_newcarrier as 'Info',
	crr_reason as 'Reason',
	crr_note as 'Note',
	crr_user as 'User',
	crr_lastupdated as 'Last Updated'
from carrierremovedreason

union

select 
	car_id as 'CarId',
	'Rating' as 'Type',
	cra_id as 'ID',
	lgh_number as 'LegNumber',
	'Rate' + ': ' + cast(cra_rating as varchar(5)) as 'Info',
	cra_reason as 'Reason',
	cra_note as 'Note',
	cra_user as 'User',
	cra_lastupdated as 'Last Updated'
from carrierrating

union

select 
	ccl_sentid as 'CarId',
	'Confirm' as 'Type',
	ccl_id as 'ID',
	--ord_hdrnumber as 'OrdHdrNumber',
	lgh_number as 'LegNumber',
	ccl_senttype + ': ' + ccl_sentid + ' | ' + convert(varchar, cast(ccl_amount as money)) as 'Info',
	ccl_reason as 'Reason',
	NULL as Note,
	ccl_user as 'User',
	ccl_lastupdated as 'Last Updated'
from CarrierConfirmLog

GO
GRANT SELECT ON  [dbo].[CarrierLoggingView] TO [public]
GO
