CREATE TABLE [dbo].[terminaldetail]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ord_number_prefix] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__terminald__ord_n__108A1048] DEFAULT (''),
[ord_number_length] [int] NULL CONSTRAINT [DF__terminald__ord_n__117E3481] DEFAULT ((0)),
[num_doors] [int] NULL CONSTRAINT [DF__terminald__num_d__127258BA] DEFAULT ((0)),
[ownership_type] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__terminald__owner__13667CF3] DEFAULT ('C'),
[is_relay] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__terminald__is_re__154EC565] DEFAULT ('N'),
[is_breakbulk] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__terminald__is_br__1642E99E] DEFAULT ('N'),
[is_pick_delv] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__terminald__is_pi__17370DD7] DEFAULT ('N'),
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[preference] [int] NULL CONSTRAINT [DF__terminald__prefe__182B3210] DEFAULT ((0)),
[turnaround_hours] [int] NULL CONSTRAINT [DF__terminald__turna__191F5649] DEFAULT ((0)),
[rowchgts] [timestamp] NOT NULL,
[check_stop_master] [int] NULL,
[auto_apply_reweigh] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[terminaldetail] ADD CONSTRAINT [CK__terminald__owner__145AA12C] CHECK (([ownership_type]='U' OR [ownership_type]='V' OR [ownership_type]='C'))
GO
ALTER TABLE [dbo].[terminaldetail] ADD CONSTRAINT [PK__terminal__CD425FDDCDE98A29] PRIMARY KEY CLUSTERED ([cmp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[terminaldetail] TO [public]
GO
GRANT INSERT ON  [dbo].[terminaldetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[terminaldetail] TO [public]
GO
GRANT SELECT ON  [dbo].[terminaldetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[terminaldetail] TO [public]
GO
