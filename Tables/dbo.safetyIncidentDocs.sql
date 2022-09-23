CREATE TABLE [dbo].[safetyIncidentDocs]
(
[sid_Ident] [int] NOT NULL IDENTITY(1, 1),
[srp_ID] [int] NOT NULL,
[sid_number] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[srp_number] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[abbr] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scl_Ident] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[safetyIncidentDocs] ADD CONSTRAINT [pk_sid_ID] PRIMARY KEY CLUSTERED ([sid_Ident]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[safetyIncidentDocs] TO [public]
GO
GRANT INSERT ON  [dbo].[safetyIncidentDocs] TO [public]
GO
GRANT REFERENCES ON  [dbo].[safetyIncidentDocs] TO [public]
GO
GRANT SELECT ON  [dbo].[safetyIncidentDocs] TO [public]
GO
GRANT UPDATE ON  [dbo].[safetyIncidentDocs] TO [public]
GO
