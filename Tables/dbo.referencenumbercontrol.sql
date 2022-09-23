CREATE TABLE [dbo].[referencenumbercontrol]
(
[rfc_id] [int] NOT NULL IDENTITY(1, 1),
[rfc_company] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rfc_ref_table] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rfc_ref_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rfc_req_save] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rfc_req_complete] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[referencenumbercontrol] ADD CONSTRAINT [PK_referencenumbercontrol] PRIMARY KEY CLUSTERED ([rfc_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[referencenumbercontrol] TO [public]
GO
GRANT INSERT ON  [dbo].[referencenumbercontrol] TO [public]
GO
GRANT REFERENCES ON  [dbo].[referencenumbercontrol] TO [public]
GO
GRANT SELECT ON  [dbo].[referencenumbercontrol] TO [public]
GO
GRANT UPDATE ON  [dbo].[referencenumbercontrol] TO [public]
GO
