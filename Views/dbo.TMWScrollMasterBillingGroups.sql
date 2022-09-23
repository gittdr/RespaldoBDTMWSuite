SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[TMWScrollMasterBillingGroups] AS

select dbh.ord_billto as BillTo,
	dbh.dbh_id as MasterBillingGrpID,
	dbh.dbsd_id_createbill as BillingSchedDetailID,
	dbh.dbse_id_createbill as BillingSchedEntityID,
	dbsd.dbsd_enddate as EndDate,
	dbh.dbh_status as MasterBillStatus,
	ivh.*
from dedbillingheader dbh with (nolock)
join dedbillingscheduledetail dbsd with (nolock)
	on dbh.dbsd_id_createbill = dbsd.dbsd_id
join dedbillingdetail dbd with (nolock)
	on dbd.dbh_id = dbh.dbh_id
join invoiceheader ivh with (nolock)
	on dbd.ivh_hdrnumber = ivh.ivh_hdrnumber

GO
GRANT DELETE ON  [dbo].[TMWScrollMasterBillingGroups] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWScrollMasterBillingGroups] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWScrollMasterBillingGroups] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWScrollMasterBillingGroups] TO [public]
GO
