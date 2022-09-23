CREATE TABLE [dbo].[fueltax]
(
[ft_sequence] [int] NOT NULL,
[lgh_number] [int] NULL,
[ord_hdrnumber] [int] NULL,
[mov_number] [int] NULL,
[stp_number] [int] NULL,
[ft_date] [datetime] NULL,
[ft_origin] [int] NULL,
[ft_destination] [int] NULL,
[trc_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ft_event] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ft_meter] [float] NULL,
[ft_uom] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ft_state] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ft_free] [float] NULL,
[ft_toll] [float] NULL,
[ft_due] [float] NULL,
[ft_paid] [float] NULL,
[ft_loaded_yn] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NULL,
[ft_total] [float] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[fueltax] TO [public]
GO
GRANT INSERT ON  [dbo].[fueltax] TO [public]
GO
GRANT REFERENCES ON  [dbo].[fueltax] TO [public]
GO
GRANT SELECT ON  [dbo].[fueltax] TO [public]
GO
GRANT UPDATE ON  [dbo].[fueltax] TO [public]
GO
