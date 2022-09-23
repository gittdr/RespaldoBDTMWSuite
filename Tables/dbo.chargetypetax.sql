CREATE TABLE [dbo].[chargetypetax]
(
[chttax_id] [int] NOT NULL IDENTITY(1, 1),
[cht_number] [int] NOT NULL,
[cht_tax1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_tax2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_tax3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_tax4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_tax5] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_tax6] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_tax7] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_tax8] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_tax9] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_tax10] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[chargetypetax] ADD CONSTRAINT [PK_chttypetax] PRIMARY KEY CLUSTERED ([chttax_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[chargetypetax] TO [public]
GO
GRANT INSERT ON  [dbo].[chargetypetax] TO [public]
GO
GRANT REFERENCES ON  [dbo].[chargetypetax] TO [public]
GO
GRANT SELECT ON  [dbo].[chargetypetax] TO [public]
GO
GRANT UPDATE ON  [dbo].[chargetypetax] TO [public]
GO
