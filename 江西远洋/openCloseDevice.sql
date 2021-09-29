select * from devicemonitor order by type, reportTime desc;

-- 含序号的分组
select @rn:= CASE WHEN @gid = t.type THEN @rn + 1 ELSE 1 END rn, @gid:= t.type as gid, t.type, t.v, t.reportTime 
from (select @rn:=0,@gid:='') A, (select type, value v, reportTime from devicemonitor order by type, reportTime desc)  t  ;


-- v_devicemonitor_zip
select a.type,a.v,a.reportTime from
(
select @rn1:= CASE WHEN @gid1 = t.type THEN @rn1 + 1 ELSE 1 END rn, @gid1:= t.type as gid, t.type, t.v, t.reportTime 
from (select @rn1:=0,@gid1:='') A, (select type, value v, reportTime from devicemonitor order by type, reportTime desc)  t
) a,
(
select @rn2:= CASE WHEN @gid2 = t.type THEN @rn2 + 1 ELSE 1 END rn, @gid2:= t.type as gid, t.type, t.v, t.reportTime 
from (select @rn2:=0,@gid2:='') A, (select type, value v, reportTime from devicemonitor order by type, reportTime desc)  t
) b
 where a.type=b.type and a.rn=b.rn-1 and a.v!=b.v;

-- 含序号的分组 v_devicemonitor_zip
select @rn11:= CASE WHEN @gid11 = aa.type THEN @rn11 + 1 ELSE 1 END rn, @gid11:= aa.type as gid, aa.*
from 
(select @rn11:=0,@gid11:='') A, 
(
	select a.type,a.v,a.reportTime from
	(
	select @rn1:= CASE WHEN @gid1 = t.type THEN @rn1 + 1 ELSE 1 END rn, @gid1:= t.type as gid, t.type, t.v, t.reportTime 
	from (select @rn1:=0,@gid1:='') A, (select type, value v, reportTime from devicemonitor order by type, reportTime desc)  t
	) a,
	(
	select @rn2:= CASE WHEN @gid2 = t.type THEN @rn2 + 1 ELSE 1 END rn, @gid2:= t.type as gid, t.type, t.v, t.reportTime 
	from (select @rn2:=0,@gid2:='') A, (select type, value v, reportTime from devicemonitor order by type, reportTime desc)  t
	) b
	where a.type=b.type and a.rn=b.rn-1 and a.v!=b.v
) aa 

-- 合并
select aaa.type, aaa.reportTime startTime, bbb.reportTime endTime from
(
	select @rn11:= CASE WHEN @gid11 = aa.type THEN @rn11 + 1 ELSE 1 END rn, @gid11:= aa.type as gid, aa.*
	from 
	(select @rn11:=0,@gid11:='') A, 
	(
		select a.type,a.v,a.reportTime from
		(
		select @rn1:= CASE WHEN @gid1 = t.type THEN @rn1 + 1 ELSE 1 END rn, @gid1:= t.type as gid, t.type, t.v, t.reportTime 
		from (select @rn1:=0,@gid1:='') A, (select type, value v, reportTime from devicemonitor order by type, reportTime desc)  t
		) a,
		(
		select @rn2:= CASE WHEN @gid2 = t.type THEN @rn2 + 1 ELSE 1 END rn, @gid2:= t.type as gid, t.type, t.v, t.reportTime 
		from (select @rn2:=0,@gid2:='') A, (select type, value v, reportTime from devicemonitor order by type, reportTime desc)  t
		) b
		where a.type=b.type and a.rn=b.rn-1 and a.v!=b.v
	) aa 
) aaa
left join 
(
	select @rn11:= CASE WHEN @gid11 = aa.type THEN @rn11 + 1 ELSE 1 END rn, @gid11:= aa.type as gid, aa.*
	from 
	(select @rn11:=0,@gid11:='') A, 
	(
		select a.type,a.v,a.reportTime from
		(
		select @rn1:= CASE WHEN @gid1 = t.type THEN @rn1 + 1 ELSE 1 END rn, @gid1:= t.type as gid, t.type, t.v, t.reportTime 
		from (select @rn1:=0,@gid1:='') A, (select type, value v, reportTime from devicemonitor order by type, reportTime desc)  t
		) a,
		(
		select @rn2:= CASE WHEN @gid2 = t.type THEN @rn2 + 1 ELSE 1 END rn, @gid2:= t.type as gid, t.type, t.v, t.reportTime 
		from (select @rn2:=0,@gid2:='') A, (select type, value v, reportTime from devicemonitor order by type, reportTime desc)  t
		) b
		where a.type=b.type and a.rn=b.rn-1 and a.v!=b.v
	) aa 
) bbb
on aaa.type=bbb.type and aaa.rn=bbb.rn+1 where aaa.v=1 order by aaa.type, aaa.reportTime desc;