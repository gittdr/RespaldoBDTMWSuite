SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[trc_trl_tare_gross_sp] @name varchar(10), @number varchar (13)    as 

If upper(@name) = 'TRACTOR' 
	select trc_axlgrp1_tarewgt axlgrp1_tarewgt,
			trc_axlgrp2_tarewgt axlgrp2_tarewgt,
			trc_axlgrp1_grosswgt axlgrp1_grosswgt,
			trc_axlgrp2_grosswgt axlgrp2_grosswgt
	from tractorprofile
	where trc_number = @number

If upper(@name) = 'TRAILER' 
	select trl_axlgrp1_tarewgt axlgrp1_tarewgt,
			trl_axlgrp2_tarewgt axlgrp2_tarewgt,
			trl_axlgrp1_grosswgt axlgrp1_grosswgt,
			trl_axlgrp2_grosswgt axlgrp2_grosswgt
	from trailerprofile
	where trl_id = @number
GO
GRANT EXECUTE ON  [dbo].[trc_trl_tare_gross_sp] TO [public]
GO
