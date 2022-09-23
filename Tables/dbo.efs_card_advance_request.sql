CREATE TABLE [dbo].[efs_card_advance_request]
(
[ecar_id] [int] NOT NULL IDENTITY(1, 1),
[ecar_asgn_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ecar_asgn_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ecar_amount] [money] NOT NULL,
[ecar_reasoncode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ecar_accountcode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ecar_custcode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ecar_cardnumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ecar_comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_number] [int] NOT NULL,
[mov_number] [int] NOT NULL,
[ord_hdrnumber] [int] NOT NULL,
[ecar_request_user] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ecar_request_time] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[it_efs_card_advance_request] ON [dbo].[efs_card_advance_request] FOR INSERT AS   
SET NOCOUNT ON

DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

update efs_card_advance_request
   set ecar_request_user = @tmwuser,
       ecar_request_time = getdate()
  from inserted
 where inserted.ecar_id = efs_card_advance_request.ecar_id
GO
ALTER TABLE [dbo].[efs_card_advance_request] ADD CONSTRAINT [pk_efs_card_advance_request] PRIMARY KEY CLUSTERED ([ecar_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_etr_asgn_id_date] ON [dbo].[efs_card_advance_request] ([ecar_asgn_type], [ecar_asgn_id], [ecar_request_time]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[efs_card_advance_request] ADD CONSTRAINT [fk_ecar_cashcard] FOREIGN KEY ([ecar_cardnumber], [ecar_accountcode], [ecar_custcode]) REFERENCES [dbo].[cashcard] ([crd_cardnumber], [crd_accountid], [crd_customerid])
GO
GRANT INSERT ON  [dbo].[efs_card_advance_request] TO [public]
GO
GRANT SELECT ON  [dbo].[efs_card_advance_request] TO [public]
GO
GRANT UPDATE ON  [dbo].[efs_card_advance_request] TO [public]
GO
