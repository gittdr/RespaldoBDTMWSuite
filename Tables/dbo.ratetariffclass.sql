CREATE TABLE [dbo].[ratetariffclass]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[asgn_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asgn_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tariff_class] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate_class] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[start_zip] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[end_zip] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[all_greater] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[calc_seq] [int] NULL,
[rowchgts] [timestamp] NOT NULL,
[pricing_terms] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[startdate] [datetime] NULL,
[enddate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ratetariffclass] ADD CONSTRAINT [PK__ratetari__3213E83F4B890DE3] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ratetariffclass] TO [public]
GO
GRANT INSERT ON  [dbo].[ratetariffclass] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ratetariffclass] TO [public]
GO
GRANT SELECT ON  [dbo].[ratetariffclass] TO [public]
GO
GRANT UPDATE ON  [dbo].[ratetariffclass] TO [public]
GO
