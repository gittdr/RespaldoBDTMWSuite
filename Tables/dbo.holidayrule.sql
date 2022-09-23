CREATE TABLE [dbo].[holidayrule]
(
[hrule_id] [int] NOT NULL IDENTITY(1, 1),
[hrule_code] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hrule_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hrule_holiday] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hrule_UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hrule_updatedDate] [datetime] NULL,
[hrule_holiday_group] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[holidayrule] ADD CONSTRAINT [pk_holidayrules] PRIMARY KEY CLUSTERED ([hrule_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[holidayrule] ADD CONSTRAINT [uk_hrulecode] UNIQUE NONCLUSTERED ([hrule_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[holidayrule] TO [public]
GO
GRANT INSERT ON  [dbo].[holidayrule] TO [public]
GO
GRANT REFERENCES ON  [dbo].[holidayrule] TO [public]
GO
GRANT SELECT ON  [dbo].[holidayrule] TO [public]
GO
GRANT UPDATE ON  [dbo].[holidayrule] TO [public]
GO
