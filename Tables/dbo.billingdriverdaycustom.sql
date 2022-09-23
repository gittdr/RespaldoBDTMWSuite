CREATE TABLE [dbo].[billingdriverdaycustom]
(
[bdd_id] [int] NOT NULL IDENTITY(1, 1),
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bdd_day] [datetime] NULL,
[bdd_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bdd_created_date] [datetime] NOT NULL,
[bdd_created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[bdd_modified_date] [datetime] NOT NULL,
[bdd_modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[billingdriverdaycustom] ADD CONSTRAINT [PK_billingdriverdaycustom] PRIMARY KEY NONCLUSTERED ([bdd_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[billingdriverdaycustom] TO [public]
GO
GRANT INSERT ON  [dbo].[billingdriverdaycustom] TO [public]
GO
GRANT REFERENCES ON  [dbo].[billingdriverdaycustom] TO [public]
GO
GRANT SELECT ON  [dbo].[billingdriverdaycustom] TO [public]
GO
GRANT UPDATE ON  [dbo].[billingdriverdaycustom] TO [public]
GO
