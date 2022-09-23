CREATE TABLE [dbo].[nce_group_membership]
(
[ncem_group_id] [int] NOT NULL,
[ncem_email_person_id] [int] NOT NULL,
[created] [datetime] NULL,
[created_by] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[nce_group_membership_tgi]
ON 			   [dbo].[nce_group_membership]
FOR INSERT, UPDATE
AS

BEGIN

    update nce_group_membership
    set created    = getdate(),
       created_by = SUSER_SNAME()
    from inserted
    where nce_group_membership.ncem_group_id = inserted.ncem_group_id
    and nce_group_membership.ncem_email_person_id = inserted.ncem_email_person_id
    
END

GO
ALTER TABLE [dbo].[nce_group_membership] ADD CONSTRAINT [nce_group_membership_pk] PRIMARY KEY CLUSTERED ([ncem_group_id], [ncem_email_person_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[nce_group_membership] TO [public]
GO
GRANT INSERT ON  [dbo].[nce_group_membership] TO [public]
GO
GRANT SELECT ON  [dbo].[nce_group_membership] TO [public]
GO
GRANT UPDATE ON  [dbo].[nce_group_membership] TO [public]
GO
