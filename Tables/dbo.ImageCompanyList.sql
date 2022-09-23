CREATE TABLE [dbo].[ImageCompanyList]
(
[icl_ID] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[icl_transcode] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImageCompanyList] ADD CONSTRAINT [PK__ImageCompanyList__61F21CB1] PRIMARY KEY CLUSTERED ([icl_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_cmpid] ON [dbo].[ImageCompanyList] ([cmp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ImageCompanyList] TO [public]
GO
GRANT INSERT ON  [dbo].[ImageCompanyList] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ImageCompanyList] TO [public]
GO
GRANT SELECT ON  [dbo].[ImageCompanyList] TO [public]
GO
GRANT UPDATE ON  [dbo].[ImageCompanyList] TO [public]
GO
