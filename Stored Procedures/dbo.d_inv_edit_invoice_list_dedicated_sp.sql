SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[d_inv_edit_invoice_list_dedicated_sp] (	
@dbh_id				int
)
AS

DECLARE @notes_count int,
@Order int,
@nextrec int,
@mov_number int,
@key						char(18), 
@table					char(18) , 
@Billto					varchar(8),
@Shipper			varchar(8),
@Consignee	varchar(8),
@CmdCode   varchar(8),
@Commodity varchar(8),
@Tractor      varchar(8), 
@Trailer1			varchar(13),
@Trailer2			varchar(13),
@Driver1				varchar(8),
@Driver2				varchar(8),
@Carrier				varchar(8)






CREATE table #results (
ivh_invoicenumber char(12),
ivh_totalcharge money,
ivh_invoicecharge money,
ivh_allocated money,
ivh_billto varchar(8),
ivh_shipper varchar(8),
ivh_consignee varchar(8),
ivh_deliverydate datetime,
ivh_shipdate datetime,
ivh_billdate datetime,
ivh_revtype1 varchar(6),
ivh_revtype2 varchar(6),
ivh_revtype3 varchar(6),
ivh_revtype4 varchar(6),
ivh_booked_revtype1 char(12),
ivh_mbstatus char(6),
dbd_id int,
dbh_id int,
ivh_hdrnumber int,
created_date datetime,
created_user char(20),
modified_date datetime,
modified_user char(20),
include_flag char(1),
ord_hdrnumber int,
notes_count int,
ivh_definition varchar(6),
retrieval_date datetime, --PTS 53500 SGB
allocate_flag char(1)	 --PTS 57140 NQIAO
)

Insert into #results
SELECT C.ivh_invoicenumber,
		(SELECT SUM(ISNULL(ivd_charge, 0))
		   FROM invoicedetail
		  WHERE invoicedetail.ivh_hdrnumber = C.ivh_hdrnumber) ivh_totalcharge,
		(SELECT SUM(ISNULL(ivd_charge, 0))
		   FROM invoicedetail
		  WHERE invoicedetail.ivh_hdrnumber = C.ivh_hdrnumber
		    AND (ISNULL(invoicedetail.ivd_allocated_ivd_number, 0) = 0 OR isnull(ivd_allocation_type,'') = 'RCNCLT')) ivh_invoicecharge, -- PTS 53514
		(SELECT SUM(ISNULL(ivd_charge, 0))
		   FROM invoicedetail
		  WHERE invoicedetail.ivh_hdrnumber = C.ivh_hdrnumber
		    AND ISNULL(invoicedetail.ivd_allocated_ivd_number, 0) > 0 AND isnull(ivd_allocation_type,'') <> 'RCNCLT')  ivh_allocated, -- PTS53514
		 C.ivh_billto, 
		 C.ivh_shipper, 
		 C.ivh_consignee,
		 C.ivh_deliverydate,
		 C.ivh_shipdate, 
		 C.ivh_billdate, 
		 C.ivh_revtype1, 
		 C.ivh_revtype2, 
		 C.ivh_revtype3, 
		 C.ivh_revtype4, 
		 C.ivh_booked_revtype1, 
		 C.ivh_mbstatus, 
		 B.dbd_id, 
		 B.dbh_id, 
		 B.ivh_hdrnumber, 
		 B.created_date,
		 B.created_user, 
		 B.modified_date, 
		 B.modified_user, 'N' as include_flag,
		C.ord_hdrnumber,
		0	,
		C.ivh_definition,
		B.dbd_retrieval_date, --PTS 53500 SGB
		C.ivh_dballocate_flag --PTS 57140 NQIAO	
  FROM dedbillingdetail B JOIN invoiceheader C ON B.ivh_hdrnumber = C.ivh_hdrnumber 
 WHERE B.dbh_id = @dbh_id
        

		select  @nextrec = min(ivh_hdrnumber) from #results
    While @nextrec is not null
      BEGIN	
    
			--Select @Order = ord_hdrnumber from #results where ivh_hdrnumber = @nextrec
			Select 
			@mov_number	= isnull(mov_number,0),
			@Billto					= isnull(ivh_Billto,'UNKNOWN'),
			@Shipper			= isnull(ivh_shipper,'UNKNOWN'),
			@Consignee	= isnull(ivh_consignee,'UNKNOWN'),
			@Tractor      = isnull(ivh_tractor,'UNKNOWN'),
			@Trailer1				= isnull(ivh_trailer,'UNKNOWN'),
			@Trailer2			= isnull(ivh_trailer2,'UNKNOWN'),
			@Driver1				= isnull(ivh_driver,'UNKNOWN'),
			@Driver2				= isnull(ivh_driver2,'UNKNOWN'),
			@Carrier				= isnull(ivh_carrier,'UNKNOWN'),
			@CmdCode   = isnull(ivh_order_cmd_code,'UNKNOWN'),
			@Order = isnull(ord_hdrnumber,0)
			From invoiceheader where ivh_hdrnumber = @nextrec
		
				
			EXEC @notes_count = d_notes_check_sp	2, 
			@mov_number, 
			@Order, 
			@nextrec, 
			@Driver1	, 
			@Driver2, 
			@Tractor, 
			@Trailer1, 
			@Trailer2, 
			@carrier, 
			@Shipper, 
			@Consignee, 
			@Billto, 
			0,
			@CmdCode,
			'',
			0
			-- DEBUG Statement
			--select @order,@nextrec,@notes_count
			   
			Update #results	
			Set Notes_count = @notes_count
			Where 	ivh_hdrnumber = @nextrec
			
			select @nextrec = min(ivh_hdrnumber) from #results where ivh_hdrnumber > @nextrec	
     END
		       

          

       
       
Select        ivh_invoicenumber ,
ivh_totalcharge,
ivh_invoicecharge,
ivh_allocated,
ivh_billto,
ivh_shipper,
ivh_consignee,
ivh_deliverydate,
ivh_shipdate,
ivh_billdate,
ivh_revtype1,
ivh_revtype2,
ivh_revtype3,
ivh_revtype4,
ivh_booked_revtype1,
ivh_mbstatus,
dbd_id,
dbh_id,
ivh_hdrnumber,
created_date,
created_user,
modified_date,
modified_user,
include_flag,
ord_hdrnumber,
notes_count,
ivh_definition,
retrieval_date, --PTS 53500 SGB
allocate_flag	--PTS 57140 NQIAO
from #results         
        
       
       
GO
GRANT EXECUTE ON  [dbo].[d_inv_edit_invoice_list_dedicated_sp] TO [public]
GO
