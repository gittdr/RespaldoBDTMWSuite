CREATE TABLE [dbo].[containerperdiem_rates]
(
[cpdr_cpd_id] [int] NOT NULL,
[cpdr_id] [int] NOT NULL IDENTITY(1, 1),
[cpdr_iso_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpdr_length] [float] NULL CONSTRAINT [DF__container__cpdr___33702C76] DEFAULT ((0)),
[cpdr_trltype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpdr_trltype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpdr_trltype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpdr_trltype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpdr_freedays] [int] NULL CONSTRAINT [DF__container__cpdr___346450AF] DEFAULT ((0)),
[cpdr_days1] [int] NULL CONSTRAINT [DF__container__cpdr___355874E8] DEFAULT ((0)),
[cpdr_charge1] [money] NULL CONSTRAINT [DF__container__cpdr___364C9921] DEFAULT ((0)),
[cpdr_days2] [int] NULL CONSTRAINT [DF__container__cpdr___3740BD5A] DEFAULT ((0)),
[cpdr_charge2] [money] NULL CONSTRAINT [DF__container__cpdr___3834E193] DEFAULT ((0)),
[cpdr_days3] [int] NULL CONSTRAINT [DF__container__cpdr___392905CC] DEFAULT ((0)),
[cpdr_charge3] [money] NULL CONSTRAINT [DF__container__cpdr___3A1D2A05] DEFAULT ((0)),
[cpdr_days4] [int] NULL CONSTRAINT [DF__container__cpdr___3B114E3E] DEFAULT ((0)),
[cpdr_charge4] [money] NULL CONSTRAINT [DF__container__cpdr___3C057277] DEFAULT ((0)),
[cpdr_calc_order] [int] NULL CONSTRAINT [DF__container__cpdr___3CF996B0] DEFAULT ((0)),
[rowchgts] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[containerperdiem_rates] ADD CONSTRAINT [PK__containerperdiem__327C083D] PRIMARY KEY CLUSTERED ([cpdr_cpd_id], [cpdr_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[containerperdiem_rates] TO [public]
GO
GRANT INSERT ON  [dbo].[containerperdiem_rates] TO [public]
GO
GRANT REFERENCES ON  [dbo].[containerperdiem_rates] TO [public]
GO
GRANT SELECT ON  [dbo].[containerperdiem_rates] TO [public]
GO
GRANT UPDATE ON  [dbo].[containerperdiem_rates] TO [public]
GO
