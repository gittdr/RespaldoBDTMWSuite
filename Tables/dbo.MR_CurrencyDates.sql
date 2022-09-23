CREATE TABLE [dbo].[MR_CurrencyDates]
(
[cur_datename] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cur_tabletype] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cur_defaultYN] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MR_CurrencyDates] ADD CONSTRAINT [PK_MR_CurrencyDates] PRIMARY KEY CLUSTERED ([cur_datename], [cur_tabletype]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MR_CurrencyDates] TO [public]
GO
GRANT INSERT ON  [dbo].[MR_CurrencyDates] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MR_CurrencyDates] TO [public]
GO
GRANT SELECT ON  [dbo].[MR_CurrencyDates] TO [public]
GO
GRANT UPDATE ON  [dbo].[MR_CurrencyDates] TO [public]
GO
