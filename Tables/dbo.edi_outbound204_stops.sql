CREATE TABLE [dbo].[edi_outbound204_stops]
(
[ob_204id] [int] NULL,
[ord_hdrnumber] [int] NULL,
[stp_number] [int] NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_name] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_address1] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_address2] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_city] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_sequence] [int] NULL,
[stp_event] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_weight] [float] NULL,
[stp_weightunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_count] [decimal] (10, 2) NULL,
[stp_countunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_volume] [float] NULL,
[stp_volumeunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_arrivaldate] [datetime] NULL,
[stp_departuredate] [datetime] NULL,
[stp_schdtearliest] [datetime] NULL,
[stp_schdtlatest] [datetime] NULL,
[stp_trailer1] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_trailer2] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_location_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_phone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_contact] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_county] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_trailertype] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_trailer3] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_trailer4] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_eos_ob_204id] ON [dbo].[edi_outbound204_stops] ([ob_204id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_eos_ord_hdrnumber] ON [dbo].[edi_outbound204_stops] ([ord_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_outbound204_stops] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_outbound204_stops] TO [public]
GO
GRANT REFERENCES ON  [dbo].[edi_outbound204_stops] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_outbound204_stops] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_outbound204_stops] TO [public]
GO
