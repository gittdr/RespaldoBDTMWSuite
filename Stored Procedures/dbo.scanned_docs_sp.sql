SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[scanned_docs_sp] @p_cmpid varchar(8)
as


/**
 * 
 * NAME:
 * dbo.scanned_docs_sp
 *
 * TYPE:
 * [StoredProcedure]
 *
 * DESCRIPTION:
 * This procedure returns data from the imaging_scanneddoc table for maintenance
 *
 * RETURNS:
 * NONE
 *
 *
 * REFERENCES: (NONE)

 * 
 * REVISION HISTORY:
 * 6/4/09 PTS47627 created
 **/


select
cmp_id ,
isd_rollontrip ,
isd_doctype,isd_doctype_t = 'PaperWork' ,
isd_docdelivery , isd_docdelivery_t = 'ScannedDocDelivery',
isd_email_address 
from imaging_scanneddoc 
where cmp_id = @p_cmpid
GO
GRANT EXECUTE ON  [dbo].[scanned_docs_sp] TO [public]
GO
