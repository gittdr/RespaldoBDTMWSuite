CREATE TABLE [dbo].[ship_conditions]
(
[sc_id] [int] NOT NULL IDENTITY(1, 1),
[lgh_number] [int] NOT NULL,
[sc_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sc_group] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sc_quantity] [float] NULL,
[sc_units] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NOT NULL,
[updatedt] [datetime] NULL CONSTRAINT [DF__ship_cond__updat__6269183F] DEFAULT (getdate()),
[updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ship_conditions] ADD CONSTRAINT [pk_ship_conditions_sc_id] PRIMARY KEY CLUSTERED ([sc_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ship_conditions_lgh_number] ON [dbo].[ship_conditions] ([lgh_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ship_conditions] TO [public]
GO
GRANT INSERT ON  [dbo].[ship_conditions] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ship_conditions] TO [public]
GO
GRANT SELECT ON  [dbo].[ship_conditions] TO [public]
GO
GRANT UPDATE ON  [dbo].[ship_conditions] TO [public]
GO
