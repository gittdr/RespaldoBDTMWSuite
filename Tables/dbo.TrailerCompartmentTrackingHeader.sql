CREATE TABLE [dbo].[TrailerCompartmentTrackingHeader]
(
[tcth_id] [int] NOT NULL IDENTITY(1, 1),
[trl_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tcth_compartment] [int] NOT NULL,
[lgh_number] [int] NOT NULL,
[tcth_createdby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tcth_createddate] [datetime] NULL,
[tcth_lastupdatedby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tcth_lastupdatedate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TrailerCompartmentTrackingHeader] ADD CONSTRAINT [PK_TrailerCompartmentTrackingHeader] PRIMARY KEY CLUSTERED ([tcth_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TrailerCompartmentTrackingHeader] TO [public]
GO
GRANT INSERT ON  [dbo].[TrailerCompartmentTrackingHeader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TrailerCompartmentTrackingHeader] TO [public]
GO
GRANT SELECT ON  [dbo].[TrailerCompartmentTrackingHeader] TO [public]
GO
GRANT UPDATE ON  [dbo].[TrailerCompartmentTrackingHeader] TO [public]
GO
