CREATE TABLE [dbo].[FuelInvOverrides]
(
[inv_id] [int] NOT NULL,
[ovr_type] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ovr_integer] [int] NULL,
[ovr_string] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovr_datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FuelInvOverrides] ADD CONSTRAINT [pk_FuelInvOverrides_id_name] PRIMARY KEY CLUSTERED ([inv_id], [ovr_type]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[FuelInvOverrides] TO [public]
GO
GRANT INSERT ON  [dbo].[FuelInvOverrides] TO [public]
GO
GRANT SELECT ON  [dbo].[FuelInvOverrides] TO [public]
GO
GRANT UPDATE ON  [dbo].[FuelInvOverrides] TO [public]
GO
