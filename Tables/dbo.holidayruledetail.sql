CREATE TABLE [dbo].[holidayruledetail]
(
[hrule_id] [int] NOT NULL,
[hrd_id] [int] NOT NULL IDENTITY(1, 1),
[hrd_ObservedDayofWeek] [smallint] NULL,
[hrd_TripStartDayAdj] [smallint] NULL,
[hrd_TripStartRule] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hrd_TripStartAdj] [int] NULL,
[hrd_TripInProgRule] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hrd_TripInProgAdj] [int] NULL,
[hrd_Updatedby] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hrd_UpdatedDate] [datetime] NULL,
[hrd_firststopflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[holidayruledetail] ADD CONSTRAINT [pk_holidayruledetail] PRIMARY KEY CLUSTERED ([hrule_id], [hrd_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[holidayruledetail] TO [public]
GO
GRANT INSERT ON  [dbo].[holidayruledetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[holidayruledetail] TO [public]
GO
GRANT SELECT ON  [dbo].[holidayruledetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[holidayruledetail] TO [public]
GO
