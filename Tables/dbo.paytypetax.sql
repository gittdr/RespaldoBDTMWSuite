CREATE TABLE [dbo].[paytypetax]
(
[pyttax_id] [int] NOT NULL IDENTITY(1, 1),
[pyt_number] [int] NOT NULL,
[pyt_tax1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_tax2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_tax3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_tax4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_tax5] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_tax6] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_tax7] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_tax8] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_tax9] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_tax10] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tax_triggered_by] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__paytypeta__tax_t__735E9A17] DEFAULT ('TRIP')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[paytypetax] ADD CONSTRAINT [PK_paytypetax] PRIMARY KEY CLUSTERED ([pyttax_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[paytypetax] TO [public]
GO
GRANT INSERT ON  [dbo].[paytypetax] TO [public]
GO
GRANT REFERENCES ON  [dbo].[paytypetax] TO [public]
GO
GRANT SELECT ON  [dbo].[paytypetax] TO [public]
GO
GRANT UPDATE ON  [dbo].[paytypetax] TO [public]
GO
