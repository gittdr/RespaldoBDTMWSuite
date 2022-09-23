CREATE TABLE [dbo].[ttstimer]
(
[tmr_number] [int] NULL,
[tmr_module_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tmr_calltime] [datetime] NULL,
[tmr_caller_module] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmr_comments] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmr_item_number] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Trigger dbo.timerinsert    Script Date: 6/1/99 11:55:18 AM ******/
/****** Object:  Trigger dbo.timerinsert    Script Date: 12/10/97 5:50:31 PM ******/
create trigger [dbo].[timerinsert]
on [dbo].[ttstimer]
for insert as

update ttstimer
set 	tmr_number = (select max(tmr_number) from ttstimer) + 1
from ttstimer
where tmr_number is NULL




GO
CREATE UNIQUE CLUSTERED INDEX [tmr_idx1] ON [dbo].[ttstimer] ([tmr_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ttstimer] TO [public]
GO
GRANT INSERT ON  [dbo].[ttstimer] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ttstimer] TO [public]
GO
GRANT SELECT ON  [dbo].[ttstimer] TO [public]
GO
GRANT UPDATE ON  [dbo].[ttstimer] TO [public]
GO
