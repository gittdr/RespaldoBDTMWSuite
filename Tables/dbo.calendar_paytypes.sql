CREATE TABLE [dbo].[calendar_paytypes]
(
[cpt_id] [int] NOT NULL IDENTITY(1, 1),
[pyt_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cpt_calendar_basis] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[calendar_paytypes] TO [public]
GO
GRANT INSERT ON  [dbo].[calendar_paytypes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[calendar_paytypes] TO [public]
GO
GRANT SELECT ON  [dbo].[calendar_paytypes] TO [public]
GO
GRANT UPDATE ON  [dbo].[calendar_paytypes] TO [public]
GO
