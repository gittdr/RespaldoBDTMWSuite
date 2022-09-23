CREATE TABLE [dbo].[TariffInputTSBuildMilesManuallyList]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[TariffInputTS_Id] [int] NOT NULL,
[ord_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_number] [int] NULL,
[stp_event] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mile_typ_to_stop] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mile_typ_from_stop] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_city] [int] NULL,
[stp_zipcode] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ect_billable] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_mfh_sequence] [int] NULL,
[stp_loadstatus] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_type] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_sequence] [int] NULL,
[stopoffflag] [int] NULL,
[minsatstop] [int] NULL,
[allowdetention] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_ooa_mileage] [decimal] (19, 6) NULL,
[stp_ooa_stop] [decimal] (19, 6) NULL,
[stp_reasonlate] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_type1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_delayhours] [decimal] (19, 6) NULL,
[ord_hdrnumber] [int] NULL,
[stp_ord_mileage] [decimal] (19, 6) NULL,
[ord_no_recalc_miles] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_arrivaldate] [datetime] NULL,
[LastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__TariffInp__LastU__46E025A6] DEFAULT (getdate()),
[LastUpdateBy] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__TariffInp__LastU__47D449DF] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TariffInputTSBuildMilesManuallyList] ADD CONSTRAINT [pk_TariffInputTSBuildMilesManuallyList] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_TariffInputTSBuildMilesManuallyList_TariffInputTS_Id] ON [dbo].[TariffInputTSBuildMilesManuallyList] ([TariffInputTS_Id]) INCLUDE ([Id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TariffInputTSBuildMilesManuallyList] ADD CONSTRAINT [fk_TariffInputTSBuildMilesManuallyList_TariffInputTS_Id] FOREIGN KEY ([TariffInputTS_Id]) REFERENCES [dbo].[TariffInputTS] ([Id]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[TariffInputTSBuildMilesManuallyList] TO [public]
GO
GRANT INSERT ON  [dbo].[TariffInputTSBuildMilesManuallyList] TO [public]
GO
GRANT SELECT ON  [dbo].[TariffInputTSBuildMilesManuallyList] TO [public]
GO
GRANT UPDATE ON  [dbo].[TariffInputTSBuildMilesManuallyList] TO [public]
GO
