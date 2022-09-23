CREATE TABLE [dbo].[pegasus_import_documents]
(
[value_id] [int] NOT NULL IDENTITY(1, 1),
[ord_hdrnumber] [int] NULL,
[ord_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[branch_number] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_shipper] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_consignee] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evt_tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evt_trailer] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evt_driver1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[origin_city] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[destination_city] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[product] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_refnum] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[load_date] [datetime] NULL,
[allocation_branch] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[invoice_number] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[doctype] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[batchid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[modified_by] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[modified_date] [datetime] NULL,
[created_by] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_date] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
    

CREATE TRIGGER [dbo].[pegasus_import_documents_tgiu]
ON 			   [dbo].[pegasus_import_documents]
FOR INSERT, UPDATE
AS
BEGIN
/*****************************************************************
NAME:       pegasus_import_documents_tgiu

PURPOSE: Update created, created_by, or updated, updated_by fields
  in the pegasus_import_documents field.  The trigger simply ensures the update and create
  fields are set correctly when records are created or updated in the table.

Revision History:

Date      Name          Reason
--------  ------------  -------------------------------
30/03/05  DBerdine      Initial creation

******************************************************************/

if (select count(*) from deleted) = 0
BEGIN
    update pegasus_import_documents
       set created_date = getdate(),
           created_by = suser_sname()
      from inserted
     where pegasus_import_documents.value_id = inserted.value_id
END
else if not (update(created_date) or update(created_by) or update(modified_date) or update(modified_by))
BEGIN
    update pegasus_import_documents
       set modified_date = getdate(),
           modified_by = suser_sname()
      from inserted
     where pegasus_import_documents.value_id = inserted.value_id
END
   
end

GO
ALTER TABLE [dbo].[pegasus_import_documents] ADD CONSTRAINT [pegasus_import_documents_pk] PRIMARY KEY CLUSTERED ([value_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pegasus_import_documents_NU2] ON [dbo].[pegasus_import_documents] ([doctype], [load_date], [branch_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pegasus_import_documents_NU3] ON [dbo].[pegasus_import_documents] ([doctype], [ord_hdrnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pegasus_import_documents_N1] ON [dbo].[pegasus_import_documents] ([ord_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[pegasus_import_documents] TO [public]
GO
GRANT INSERT ON  [dbo].[pegasus_import_documents] TO [public]
GO
GRANT SELECT ON  [dbo].[pegasus_import_documents] TO [public]
GO
GRANT UPDATE ON  [dbo].[pegasus_import_documents] TO [public]
GO
