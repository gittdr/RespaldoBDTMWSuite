SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--exec tmwsuite.[dbo].[d_get_tolls_sp_JR_ELEOS] 'O',282324,'sa'

--go

CREATE PROC [dbo].[d_get_tolls_sp_JR_ELEOS] @tollfilter char(1), @number int, @usr varchar(20) AS 
/*
INPUT PARMS:

tollfilter:  This input parm determines what to look the tolls up by
Valid values:  
1) 'O'      Order
2) 'L'      Trip Segment

@number:		key to lookup
*/

--Obtener la orden


declare @segments table(ord_hdrnumber	int				NULL,
						lgh_number		int				NULL, 
						mov_number		int				NULL,
						stp_sequence	int				NULL,
                        orig_city		int				NULL,
                        dest_city		int				NULL,
						ord_revtype1	varchar(6)		NULL,
						ord_revtype2	varchar(6)		NULL,
						ord_revtype3	varchar(6)		NULL,
						ord_revtype4	varchar(6)		NULL,
						lgh_type1		varchar(6)		NULL,
						lgh_type2		varchar(6)		NULL,
						lgh_type3		varchar(6)		NULL,
						lgh_type4		varchar(6)		NULL,
						stp_loadstatus	char(3)			NULL,
						stp_number		int				NULL,
						axle_count		int				NULL)

declare	@li_stopcounter		int,
		@dest_city			int,
		@max_sequence		int,
		@ord_hdrnumber		int,
		@stp_loadstatus		char(3),
		@axles				tinyint,
		@V_lghnumber		int,
		@axlesdolly		tinyint

-- tabla temporal para leer los legheader
DECLARE @TTNum_leg_header TABLE(
		TTLG_numero			integer not null,
		TTLG_movimiento		Integer null)

INSERT Into @TTNum_leg_header 
	SELECT 	lgh_number, mov_number
	FROM  legheader
	where mov_number = @number


If Exists ( Select count(*) From  @TTNum_leg_header )
	BEGIN -- 1.1 Si hay leghedaers 

		-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE Posiciones_Cursor CURSOR FOR 
		SELECT TTLG_numero
		FROM @TTNum_leg_header 

		OPEN Posiciones_Cursor 
			FETCH NEXT FROM Posiciones_Cursor INTO @V_lghnumber
			--Mientras la lectura sea correcta y el contador sea menos al total de registros
			WHILE @@FETCH_STATUS = 0 
			BEGIN -- del cursor Unidades_Cursor --3
			--SELECT @V_lghnumber

				--Lookup by order for invoicing
				if @tollfilter = 'O' and @number > 0
				begin
					insert into @segments (ord_hdrnumber, lgh_number, mov_number, stp_sequence, orig_city, ord_revtype1, ord_revtype2, ord_revtype3, ord_revtype4, lgh_type1, lgh_type2, lgh_type3, lgh_type4, stp_loadstatus, stp_number)
					select s.ord_hdrnumber, s.lgh_number, s.mov_number, s.stp_mfh_sequence, s.stp_city, o.ord_revtype1, o.ord_revtype2, o.ord_revtype3, o.ord_revtype4, l.lgh_type1, l.lgh_type2, l.lgh_type3, l.lgh_type4, s.stp_loadstatus, s.stp_number
					  from stops s
					  join legheader l on l.lgh_number = s.lgh_number
					  left outer join orderheader o on s.ord_hdrnumber = o.ord_hdrnumber and s.ord_hdrnumber > 0
					 where s.ord_hdrnumber = @number AND  l.trc_type2 <> 'PERM'
					 order by stp_mfh_sequence
				end

				--Lookup by leg for settlements
				else if @tollfilter = 'L' and @number > 0
				begin
					insert into @segments (ord_hdrnumber, lgh_number, mov_number, stp_sequence, orig_city, ord_revtype1, ord_revtype2, ord_revtype3, ord_revtype4, lgh_type1, lgh_type2, lgh_type3, lgh_type4, stp_loadstatus, stp_number)
					select s.ord_hdrnumber, s.lgh_number, s.mov_number, s.stp_mfh_sequence, s.stp_city, o.ord_revtype1, o.ord_revtype2, o.ord_revtype3, o.ord_revtype4, l.lgh_type1, l.lgh_type2, l.lgh_type3, l.lgh_type4, s.stp_loadstatus, s.stp_number
					  from stops s
					  join legheader l on l.lgh_number = s.lgh_number
					  left outer join orderheader o on s.ord_hdrnumber = o.ord_hdrnumber and s.ord_hdrnumber > 0
					 where s.lgh_number in (@V_lghnumber) AND  l.trc_type2 <> 'PERM'
					 

				end

				else
				begin
					--invalid search by... return nothing
					insert into @segments (ord_hdrnumber, lgh_number, mov_number, stp_sequence, orig_city, ord_revtype1, ord_revtype2, ord_revtype3, ord_revtype4, lgh_type1, lgh_type2, lgh_type3, lgh_type4, stp_loadstatus, stp_number, axle_count)
					values (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
				end

				select @max_sequence = max(stp_sequence)
				  from @segments

				select @li_stopcounter = min(isnull(stp_sequence,-1))
				  from @segments

				while @li_stopcounter <= @max_sequence
				begin
					select @dest_city = orig_city,
						   @ord_hdrnumber = ord_hdrnumber,
						   @stp_loadstatus = stp_loadstatus
					  from @segments
					 where stp_sequence = (select min(stp_sequence)
											 from @segments
											where stp_sequence > @li_stopcounter)

					update @segments
					   set ord_hdrnumber = @ord_hdrnumber
					 where stp_sequence = @li_stopcounter
					   and ord_hdrnumber = 0

					select @axles = isnull(trc_axles,0)
					  from @segments s, event e, tractorprofile t
					 where s.stp_number = e.stp_number
					   and e.evt_sequence = 1
					   and e.evt_tractor = t.trc_number
					   and s.stp_sequence = @li_stopcounter

					select @axles = @axles + isnull(trl_axles,0)
					  from @segments s, event e, trailerprofile t
					 where s.stp_number = e.stp_number
					   and e.evt_sequence = 1
					   and e.evt_trailer1 = t.trl_id
					   and s.stp_sequence = @li_stopcounter

					select @axles = @axles + isnull(trl_axles,0)
					  from @segments s, event e, trailerprofile t
					 where s.stp_number = e.stp_number
					   and e.evt_sequence = 1
					   and e.evt_trailer2 = t.trl_id
					   and s.stp_sequence = @li_stopcounter

					   select @axlesdolly =  isnull(trl_axles,0)
					  from @segments s, event e, trailerprofile t
					 where s.stp_number = e.stp_number
					   and e.evt_sequence = 1
					   and e.evt_trailer2 = t.trl_id
					   and s.stp_sequence = @li_stopcounter

					   If @axlesdolly > 0 
					   begin
					    select @axles = @axles + 2
						end


					update @segments
					   set dest_city = @dest_city,
						   stp_loadstatus = @stp_loadstatus,
						   axle_count = @axles
					 where stp_sequence = @li_stopcounter

					select @li_stopcounter = min(isnull(stp_sequence,-1))
					  from @segments
					 where stp_sequence > @li_stopcounter
				end

			FETCH NEXT FROM Posiciones_Cursor INTO @V_lghnumber
		END --1.1
		CLOSE Posiciones_Cursor 
		DEALLOCATE Posiciones_Cursor 

				--debug
				--select * from @segments

				--now remove any stops that have a NULL dest city (these will be the last stop and there is no destination for that stop)
				--delete 				from @segments
				--where dest_city is null

				--debug JR
				--select * from @segments

				--now that we have all the origin/dest pairs need to find all the tolls that match the load status
				select tb.tb_name as Caseta, t.tb_axlecount as Ejes, t.tb_cash_toll as Efectivo, t.tb_card_toll as IAVE,
				O.cty_name Origen, D.cty_name Destino
				  from @segments seg
				  join toll_route tr on seg.orig_city = tr.tr_origin_city and seg.dest_city = tr.tr_dest_city and seg.stp_loadstatus = tr.tr_loadstatus
				  join tollroute_booth_mapping trbm on trbm.tr_ident = tr.tr_ident
				  join tollbooth tb on tb.tb_ident = trbm.tb_ident
				  join toll t on t.tb_ident = tb.tb_ident and t.tb_axlecount = seg.axle_count
				  join city O on seg.orig_city = O.cty_code
				  join city D on seg.dest_city = D.cty_code

				UNION

				--also bring in any that are not specefied as loaded or MT that match the orgin/dest pair

				select tb.tb_name as Caseta, t.tb_axlecount as Ejes, t.tb_cash_toll as Efectivo, t.tb_card_toll as IAVE
				,isnull(o.cty_name,'')+ ' / '+Isnull(O.cty_state,'') Origen, isnull(D.cty_name,'')+ ' / '+Isnull(D.cty_state,'') Destino
				  from @segments seg
				  join toll_route tr on seg.orig_city = tr.tr_origin_city and seg.dest_city = tr.tr_dest_city and tr.tr_loadstatus = 'UND'
				  join tollroute_booth_mapping trbm on trbm.tr_ident = tr.tr_ident
				  join tollbooth tb on tb.tb_ident = trbm.tb_ident and tb.tb_status <> 'OUT'
				  join toll t on t.tb_ident = tb.tb_ident and t.tb_axlecount = seg.axle_count
				  join city O on seg.orig_city = O.cty_code
				  join city D on seg.dest_city = D.cty_code
				where tr.tr_ident not in(	select tr1.tr_ident
											  from @segments seg1
											  join toll_route tr1 on seg1.orig_city = tr1.tr_origin_city and seg1.dest_city = tr1.tr_dest_city and seg1.stp_loadstatus = tr1.tr_loadstatus
											  join tollroute_booth_mapping trbm1 on trbm1.tr_ident = tr1.tr_ident
											  join tollbooth tb1 on tb1.tb_ident = trbm.tb_ident and tb1.tb_status <> 'OUT'
											  join toll t1 on t1.tb_ident = tb1.tb_ident)

			--Ejecuta sp para generar los inserts

			
END



GO
