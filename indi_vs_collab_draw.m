Adjusted_error_log = Error_log;

lgd_ftsz = 17;
lb_ftsz = 17;
lwth = 1;
T_show = 500;

Good_list = [1 2 3 4 5 6 7 8 9 10];
Bad_list = [];

figure
fig_1 = semilogy(Adjusted_error_log(:,1:T_show).');
x_lb = xlabel('Iteration $t$','interpreter','latex');
y_lb = ylabel('Column-wise Error on Global Dictionary','interpreter','latex');
lgd = legend('Individual Clients','','','','','','','','','','PerMA');
lgd.FontSize = lgd_ftsz;
x_lb.FontSize = lb_ftsz;
y_lb.FontSize = lb_ftsz;
for i = 1:length(Good_list)
    fig_1(Good_list(i)).Color = "#EDB120";
    fig_1(Good_list(i)).Marker = "o";
    fig_1(Good_list(i)).LineWidth = lwth;
end
for i = 1:length(Bad_list)
    fig_1(Bad_list(i)).Color = 	"red";
    fig_1(Bad_list(i)).Marker = ".";
    fig_1(Bad_list(i)).LineWidth = lwth;
end

fig_1(11).Color = "blue";
fig_1(11).Marker = "diamond";
fig_1(11).LineWidth = 1;