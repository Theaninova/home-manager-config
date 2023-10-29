import {App, Service, Utils, Widget} from '../imports.js';
import Hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';
import {deflisten} from '../scripts/scripts.js';

const WORKSPACE_SIDE_PAD = 0.546; // rem
const NUM_OF_WORKSPACES = 9;
let lastWorkspace = 0;

const activeWorkspaceIndicator = Widget.Box({
  valign: 'center',
  halign: 'start',
  className: 'bar-ws-active-box',
  connections: [
    [Hyprland.active.workspace, (box) => {
      const ws = Hyprland.active.workspace.id;
      box.setStyle(`
                        margin-left: -${1.772 * (NUM_OF_WORKSPACES - ws + 1) + WORKSPACE_SIDE_PAD / 2 - 0.2}rem;
                    `);
      lastWorkspace = ws;
    }],
  ],
  children: [
    Widget.Label({
      valign: 'center',
      className: 'bar-ws-active',
      label: `•`,
    })
  ]
});

export const ModuleWorkspaces = () => Widget.EventBox({
  onScrollUp: () => Utils.execAsync(['bash', '-c', 'hyprctl dispatch workspace -1 &']),
  onScrollDown: () => Utils.execAsync(['bash', '-c', 'hyprctl dispatch workspace +1 &']),
  onPrimaryClickRelease: () => App.toggleWindow('overview'),
  onMiddleClickRelease: () => App.toggleWindow('osk'),
  child: Widget.Box({
    homogeneous: true,
    className: 'bar-group-center',
    children: [
      Widget.Box({
        style: `padding: 0rem ${WORKSPACE_SIDE_PAD}rem;`,
        children: [
          Widget.Box({
            halign: 'center',
            children: Array.from({length: NUM_OF_WORKSPACES}, (_, i) => i + 1).map(i => Widget.Button({
              onSecondaryClick: () => Utils.execAsync(['bash', '-c', `hyprctl dispatch workspace ${i} &`]).catch(print),
              child: Widget.Label({
                valign: 'center',
                label: `${i}`,
                className: 'bar-ws txt',
              }),
            })),
            connections: [
              [Hyprland, (box) => { // TODO: connect to the right signal so that it doesn't update too much
                const kids = box.children;
                kids.forEach((child, i) => {
                  child.child.toggleClassName('bar-ws-occupied', false);
                  child.child.toggleClassName('bar-ws-occupied-left', false);
                  child.child.toggleClassName('bar-ws-occupied-right', false);
                  child.child.toggleClassName('bar-ws-occupied-left-right', false);
                });
                const occupied = Array.from({length: NUM_OF_WORKSPACES}, (_, i) => Hyprland.getWorkspace(i + 1)?.windows > 0);
                for (let i = 0; i < occupied.length; i++) {
                  if (!occupied[i]) continue;
                  const child = kids[i];
                  child.child.toggleClassName(`bar-ws-occupied${!occupied[i - 1] ? '-left' : ''}${!occupied[i + 1] ? '-right' : ''}`, true);
                }
              }],
            ],
          }),
          activeWorkspaceIndicator,
        ]
      })
    ]
  })
});