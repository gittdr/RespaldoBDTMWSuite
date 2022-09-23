CREATE TABLE [dbo].[companypreferredcarriers]
(
[cpc_id] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[timestamp] [timestamp] NOT NULL,
[cpc_default] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__companypr__cpc_d__585D5DBC] DEFAULT ('N')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[companypreferredcarriers] ADD CONSTRAINT [pk_companypreferredcarriers_cpc_id] PRIMARY KEY CLUSTERED ([cpc_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_cpc_cmp_id] ON [dbo].[companypreferredcarriers] ([cmp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[companypreferredcarriers] TO [public]
GO
GRANT INSERT ON  [dbo].[companypreferredcarriers] TO [public]
GO
GRANT REFERENCES ON  [dbo].[companypreferredcarriers] TO [public]
GO
GRANT SELECT ON  [dbo].[companypreferredcarriers] TO [public]
GO
GRANT UPDATE ON  [dbo].[companypreferredcarriers] TO [public]
GO
