SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[image_import_insert]
  @order_number int,
  @billto varchar(8),
  @branch varchar(6),
  @shipper varchar(8),
  @consignee varchar(8),
  @tractor varchar(8),
  @trailer varchar(8),
  @driver varchar(13),
  @origin varchar(25),
  @destination varchar(25),
  @product varchar(500),
  @refnum varchar(20),
  @loaddate datetime,
  @allocation varchar(6),
  @invoice varchar(12),
  @doctype varchar(20),
  @batchid varchar(20)
AS
/*****************************************************************
NAME: image_import_insert
FILE: image_import_insert.sql

PURPOSE: Create a new record in pegasus_import_documents table.  This procedure
is called once for every image inserted into the pegasus image database.  This may not
be implemented for every pegasus client, but was implemented for Trimac.

Revision History:

Date            Name            Reason
--------        ------------    -------------------------------
17-jan-2008     kcd             Ported from Trimac system
21-jan-2008     kcd             Added code to insert/update paperwork table.  This
                                paperwork table will be queried from the imaging
                                missing documents window

select * from orderheader
EXEC image_import_insert 7500615    ,'ZZZZZZ','ZZZZ','ZZZZZZ','ZZZZZZZZ','123456','123456','ZZZZZZ','ZZZZZZZ,CO/','ZZZZZZ,ZZ/','ZZZZZZZZZZZZZZZZZZZZZZZZ',NULL,NULL,'ZZZZ',NULL,'LWU','ZZZZZZ'
******************************************************************/
declare
  @error int,
  @ret int
  

begin transaction
  
insert into pegasus_import_documents (
  ord_hdrnumber,
  ord_billto,
  branch_number,
  ord_shipper,
  ord_consignee,
  evt_tractor,
  evt_trailer,
  evt_driver1,
  origin_city,
  destination_city,
  product,
  ord_refnum,
  load_date,
  allocation_branch,
  invoice_number,
  doctype,
  batchid)
values (
  @order_number,
  @billto,
  @branch,
  @shipper,
  @consignee,
  @tractor,
  @trailer,
  @driver,
  @origin,
  @destination,
  @product,
  @refnum,
  @loaddate,
  @allocation,
  @invoice,
  @doctype,
  @batchid
)

select @error = @@error
if @error=0
  BEGIN
    COMMIT TRANSACTION
  END
ELSE
  BEGIN
    ROLLBACK TRANSACTION
    return -200
  END

select @ret = @@IDENTITY 

--Paperwork is updated only if the doctype that was imaged 
--is configured in the labelfile
if exists (select 'x' from labelfile where
labeldefinition='Paperwork' and abbr=@doctype)
BEGIN
    /*Update the paperwork table*/
    
    update paperwork
    set pw_received = 'Y'
    ,last_updatedby = 'IMAGING'
    ,last_updateddatetime = getdate()
    ,pw_imaged = 'Y'
    where ord_hdrnumber = @order_number
    and abbr = @doctype
    
    --If no rows are updated, then insert the document for this order
    if @@rowcount=0 
    BEGIN
        insert into paperwork (
        abbr,
        pw_received,
        ord_hdrnumber,
        pw_dt,
        last_updatedby,
        last_updateddatetime,
        pw_imaged)
        values 
        (
            @doctype,
            'Y',
            @order_number,
            getdate(),
            'IMAGING',
            getdate(),
            'Y'
        )
        
    END
END

select @ret as "UID"
GO
GRANT EXECUTE ON  [dbo].[image_import_insert] TO [public]
GO
