var React = require('react');

var Component = React.createClass({
  getInitialState: function () {
    return {
      value: 1,
    };
  },
  handleChange: function (event) {
    console.log(event.target.value);
  },
  render: function () {
    return <input onChange={this.handleChange} value={this.state.value} />;
  }
});

React.render(<Component/>, document.getElementById('div'));
