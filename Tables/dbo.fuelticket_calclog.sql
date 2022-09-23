CREATE TABLE [dbo].[fuelticket_calclog]
(
[fcl_rowid] [int] NOT NULL IDENTITY(1, 1),
[fcl_from_stop] [int] NOT NULL,
[fcl_to_stop] [int] NOT NULL,
[fcl_miles] [int] NOT NULL,
[fcl_mpg] [decimal] (7, 3) NULL,
[fcl_loadstatus] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fcl_carrier] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fcl_region] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fcl_engine] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fcl_axles] [int] NULL,
[fcl_loadweight] [decimal] (7, 3) NULL,
[mov_number] [int] NOT NULL,
[lgh_number] [int] NOT NULL,
[fcl_created_on] [datetime] NOT NULL,
[orden] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fuelticket_calclog] ADD CONSTRAINT [PK__fuelticket_calcl__056F2FFE] PRIMARY KEY CLUSTERED ([fcl_rowid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fcl_mov_number] ON [dbo].[fuelticket_calclog] ([mov_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fcl_mov_lgh_number] ON [dbo].[fuelticket_calclog] ([mov_number], [lgh_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[fuelticket_calclog] TO [public]
GO
GRANT INSERT ON  [dbo].[fuelticket_calclog] TO [public]
GO
GRANT SELECT ON  [dbo].[fuelticket_calclog] TO [public]
GO
GRANT UPDATE ON  [dbo].[fuelticket_calclog] TO [public]
GO
