SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[insert_userperf_data] @type int, @connect_tm datetime, @duration int,
				@extra1 varchar(15), @extra2 varchar(15) as
 insert userperfmonitor (upm_type, upm_connect_tm, upm_duration, upd_extra1, upd_extra2, upm_host)
 select @type, @connect_tm, @duration, @extra1, @extra2, host_name()
GO
GRANT EXECUTE ON  [dbo].[insert_userperf_data] TO [public]
GO
