CREATE TABLE [dbo].[RailSchedule]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QuoteNumberType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuoteNumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RailSchedule_Carrier] DEFAULT ('UNKNOWN'),
[Origin] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RailSchedule_Origin] DEFAULT ('UNKNOWN'),
[Destination] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RailSchedule_Destination] DEFAULT ('UNKNOWN'),
[EquipmentType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RailSchedule_EquipmentType] DEFAULT ('UNK'),
[ServiceLevel] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsEmpty] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RailSchedule_IsEmpty] DEFAULT ('N'),
[ExpirationDate] [datetime] NULL,
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_RailSchedule_CreatedDate] DEFAULT (getdate()),
[ModifiedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_RailSchedule_ModifiedDate] DEFAULT (getdate()),
[rs_mode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rs_origincity] [int] NULL,
[rs_originstate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rs_destcity] [int] NULL,
[rs_deststate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rs_international] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rs_effectivedt] [datetime] NULL,
[rs_trltype_exclude] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rs_trltype_include] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RailSchedule] ADD CONSTRAINT [PK_RailSchedule] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RailSchedule] ADD CONSTRAINT [IX_RailSchedule_Name] UNIQUE NONCLUSTERED ([Name]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RailSchedule] TO [public]
GO
GRANT INSERT ON  [dbo].[RailSchedule] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RailSchedule] TO [public]
GO
GRANT SELECT ON  [dbo].[RailSchedule] TO [public]
GO
GRANT UPDATE ON  [dbo].[RailSchedule] TO [public]
GO
