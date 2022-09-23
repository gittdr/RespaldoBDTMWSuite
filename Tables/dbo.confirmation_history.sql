CREATE TABLE [dbo].[confirmation_history]
(
[ch_id] [int] NOT NULL IDENTITY(1, 1),
[lgh_number] [int] NOT NULL,
[mov_number] [int] NOT NULL,
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ch_user_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ch_datetime] [datetime] NOT NULL,
[brk_lineHaul_charge] [decimal] (12, 4) NULL,
[brk_fuel_charge] [decimal] (12, 4) NULL,
[brk_accessorial_charge] [decimal] (12, 4) NULL,
[ch_confirmation_received] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ch_confirmation_sent_by] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ch_confirmation_sent_to] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[confirmation_history] ADD CONSTRAINT [PK_confirmation_history] PRIMARY KEY NONCLUSTERED ([ch_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[confirmation_history] TO [public]
GO
GRANT INSERT ON  [dbo].[confirmation_history] TO [public]
GO
GRANT REFERENCES ON  [dbo].[confirmation_history] TO [public]
GO
GRANT SELECT ON  [dbo].[confirmation_history] TO [public]
GO
GRANT UPDATE ON  [dbo].[confirmation_history] TO [public]
GO
