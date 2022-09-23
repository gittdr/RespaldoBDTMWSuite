CREATE TABLE [dbo].[pegasus_invoicelist]
(
[peg_controlnumber] [int] NULL,
[ivh_hdrnumber] [int] NULL,
[mb_number] [int] NULL,
[type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[peg_dateadded] [datetime] NULL,
[peg_status] [tinyint] NULL,
[peg_dateprocessed] [datetime] NULL,
[peg_statusmsg] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[peg_identity] [int] NOT NULL IDENTITY(1, 1),
[peg_createdby] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/*    MOD LOG

10/28/02 DPETE PTS15913 If the pegasus_invoiclist table status is updated reflect the change on the
    invoiceheader table

*/


CREATE TRIGGER [dbo].[ut_image] ON [dbo].[pegasus_invoicelist] FOR UPDATE  AS

Declare @status  tinyint, @dateprocessed  datetime, @type char(1), @hdrnumber int
If Update(peg_status) 
  Begin
	Select @status = peg_status, @dateprocessed = peg_dateprocessed, @type = type, @hdrnumber = ivh_hdrnumber
   From inserted

   If @status > 1 And @type = 'I'
     Update invoiceheader
     Set ivh_imagestatus =  @status ,
     ivh_imagestatus_date =  @dateprocessed 
     Where ivh_hdrnumber = @hdrnumber
   Else
     Begin
       If  @status > 1 And @type = 'M'
         Update invoiceheader
         Set ivh_mbimagestatus =  @status ,
         ivh_mbimagestatus_date =  @dateprocessed 
         Where ivh_hdrnumber = @hdrnumber
     End
  End


GO
CREATE NONCLUSTERED INDEX [pegasus_invoicelist_ivh] ON [dbo].[pegasus_invoicelist] ([ivh_hdrnumber]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_controlnum] ON [dbo].[pegasus_invoicelist] ([peg_controlnumber], [ivh_hdrnumber], [mb_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [uk_pegdate] ON [dbo].[pegasus_invoicelist] ([peg_dateadded]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[pegasus_invoicelist] TO [public]
GO
GRANT INSERT ON  [dbo].[pegasus_invoicelist] TO [public]
GO
GRANT REFERENCES ON  [dbo].[pegasus_invoicelist] TO [public]
GO
GRANT SELECT ON  [dbo].[pegasus_invoicelist] TO [public]
GO
GRANT UPDATE ON  [dbo].[pegasus_invoicelist] TO [public]
GO
