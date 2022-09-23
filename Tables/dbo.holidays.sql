CREATE TABLE [dbo].[holidays]
(
[holiday] [datetime] NOT NULL,
[description] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[year] [int] NULL,
[holiday_id] [int] NOT NULL IDENTITY(1, 1),
[holiday_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[holiday_group] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[holidays] ADD CONSTRAINT [pk_holiday] PRIMARY KEY CLUSTERED ([holiday_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[holidays] TO [public]
GO
GRANT INSERT ON  [dbo].[holidays] TO [public]
GO
GRANT REFERENCES ON  [dbo].[holidays] TO [public]
GO
GRANT SELECT ON  [dbo].[holidays] TO [public]
GO
GRANT UPDATE ON  [dbo].[holidays] TO [public]
GO
