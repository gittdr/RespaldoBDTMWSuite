CREATE TABLE [dbo].[schedule_holidayrules]
(
[shr_ident] [int] NOT NULL IDENTITY(1, 1),
[sch_number] [int] NOT NULL,
[hrule_id] [int] NOT NULL,
[sch_masterid] [int] NOT NULL CONSTRAINT [DF__schedule___sch_m__564EBF01] DEFAULT ((-9))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[schedule_holidayrules] ADD CONSTRAINT [pk_schedule_holidayrules] PRIMARY KEY CLUSTERED ([sch_masterid], [hrule_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[schedule_holidayrules] TO [public]
GO
GRANT INSERT ON  [dbo].[schedule_holidayrules] TO [public]
GO
GRANT REFERENCES ON  [dbo].[schedule_holidayrules] TO [public]
GO
GRANT SELECT ON  [dbo].[schedule_holidayrules] TO [public]
GO
GRANT UPDATE ON  [dbo].[schedule_holidayrules] TO [public]
GO
